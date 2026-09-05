import 'dart:math' as math;

import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../chess/game_models.dart';
import '../chess/gameplay_profile.dart';
import '../chess/stockfish_service.dart';
import '../widgets/app_background.dart';
import '../widgets/chess_board.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    required this.moves,
    required this.engine,
    required this.humanIsWhite,
    required this.versusBot,
    super.key,
  });

  final List<PlayedMove> moves;
  final StockfishService engine;
  final bool humanIsWhite;
  final bool versusBot;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final List<AnalyzedMove> _analysis = [];
  int _selectedIndex = 0;
  bool _running = true;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    try {
      for (var index = 0; index < widget.moves.length; index++) {
        if (_cancelled) return;
        final move = widget.moves[index];
        final before = await widget.engine.analyze(
          move.beforeFen,
          skillLevel: 20,
          moveTimeMs: 240,
        );
        if (_cancelled) return;
        final after = await widget.engine.analyze(
          move.afterFen,
          skillLevel: 20,
          moveTimeMs: 240,
        );
        if (_cancelled) return;

        final playedScoreForMover = -after.scoreCp;
        final rawLoss = before.scoreCp - playedScoreForMover;
        final loss = rawLoss.clamp(0, 2000).toInt();
        final best = before.bestMove;
        final exactBest = best != null && move.uci == best;
        final quality = _qualityFor(loss, exactBest: exactBest);
        final scoreAfterWhite = move.whiteMoved ? -after.scoreCp : after.scoreCp;
        final analyzed = AnalyzedMove(
          move: move,
          quality: quality,
          lossCp: loss,
          scoreAfterWhite: scoreAfterWhite.clamp(-100000, 100000).toInt(),
          bestMove: best,
          explanation: _explanation(quality, loss, best),
        );

        if (!mounted) return;
        setState(() {
          _analysis.add(analyzed);
          _selectedIndex = _analysis.length - 1;
        });
      }
      if (!_cancelled &&
          mounted &&
          widget.versusBot &&
          _analysis.length == widget.moves.length) {
        try {
          await context.app.recordGameplayAnalysis(
            summarizeGameplay(
              analysis: _analysis,
              humanIsWhite: widget.humanIsWhite,
            ),
          );
        } catch (_) {
          // A revisão continua útil mesmo se o histórico não puder ser salvo.
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'A análise foi interrompida. Dá para tentar novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  MoveQuality _qualityFor(int loss, {required bool exactBest}) {
    if (exactBest || loss <= 10) return MoveQuality.best;
    if (loss <= 25) return MoveQuality.excellent;
    if (loss <= 60) return MoveQuality.good;
    if (loss <= 120) return MoveQuality.inaccuracy;
    if (loss <= 260) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }

  String _explanation(MoveQuality quality, int loss, String? bestMove) {
    final suggestion = bestMove == null
        ? ''
        : ' O motor preferia ${_formatUci(bestMove)}.';
    return switch (quality) {
      MoveQuality.best => 'Tu encontrou uma das escolhas mais fortes da posição.',
      MoveQuality.excellent => 'Quase perfeito: a posição continuou muito saudável.$suggestion',
      MoveQuality.good => 'Um lance seguro, embora existisse uma continuação mais precisa.$suggestion',
      MoveQuality.inaccuracy => 'A posição piorou um pouco. Vale conferir o que ficou sem defesa.$suggestion',
      MoveQuality.mistake => 'Esse lance cedeu cerca de ${(loss / 100).toStringAsFixed(1)} peões de vantagem.$suggestion',
      MoveQuality.blunder => 'Aqui aconteceu a grande virada: foram cerca de ${(loss / 100).toStringAsFixed(1)} peões.$suggestion',
    };
  }

  String _formatUci(String uci) {
    if (uci.length < 4) return uci;
    final promotion = uci.length > 4 ? '=${uci[4].toUpperCase()}' : '';
    return '${uci.substring(0, 2)} → ${uci.substring(2, 4)}$promotion';
  }

  List<_ReviewMilestone> _buildMilestones() {
    if (_analysis.isEmpty) return const [];
    final milestones = <int, _ReviewMilestone>{};

    void add(_ReviewMilestone milestone) {
      milestones.putIfAbsent(milestone.moveIndex, () => milestone);
    }

    if (_analysis.length >= 4) {
      final openingIndex = math.min(9, _analysis.length - 1);
      add(
        _ReviewMilestone(
          moveIndex: openingIndex,
          eyebrow: 'ABERTURA',
          title: 'As peças entraram no jogo',
          description: 'Confere desenvolvimento, centro e segurança do rei.',
          icon: Icons.rocket_launch_rounded,
          color: const Color(0xFF8BC8FF),
        ),
      );
    }

    var criticalIndex = 0;
    for (var index = 1; index < _analysis.length; index++) {
      if (_analysis[index].lossCp > _analysis[criticalIndex].lossCp) {
        criticalIndex = index;
      }
    }
    final critical = _analysis[criticalIndex];
    add(
      _ReviewMilestone(
        moveIndex: criticalIndex,
        eyebrow: critical.lossCp >= 120 ? 'MOMENTO CRÍTICO' : 'MAIOR OSCILAÇÃO',
        title: critical.lossCp >= 260 ? 'A partida virou aqui' : 'Valia parar e calcular',
        description: critical.lossCp == 0
            ? 'Foi o ponto mais importante mesmo sem uma perda clara.'
            : 'O lance cedeu cerca de ${(critical.lossCp / 100).toStringAsFixed(1)} peões.',
        icon: critical.lossCp >= 260
            ? Icons.warning_amber_rounded
            : Icons.search_rounded,
        color: _qualityColor(critical.quality),
      ),
    );

    var previousSide = 0;
    for (var index = 0; index < _analysis.length; index++) {
      final score = _analysis[index].scoreAfterWhite;
      final side = score > 80
          ? 1
          : score < -80
              ? -1
              : 0;
      if (side != 0 && previousSide != 0 && side != previousSide) {
        add(
          _ReviewMilestone(
            moveIndex: index,
            eyebrow: 'VIRADA',
            title: 'A vantagem trocou de lado',
            description: 'Compara este lance com a sugestão do motor.',
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFFFFCB69),
          ),
        );
        break;
      }
      if (side != 0) previousSide = side;
    }

    for (var index = 10; index < _analysis.length; index++) {
      if (_isEndgame(_analysis[index].move.afterFen)) {
        add(
          _ReviewMilestone(
            moveIndex: index,
            eyebrow: 'FINAL',
            title: 'Começou outra fase',
            description: 'Com menos peças, rei ativo e peões passados valem mais.',
            icon: Icons.hourglass_bottom_rounded,
            color: const Color(0xFFB9C78A),
          ),
        );
        break;
      }
    }

    if (_analysis.length > 1) {
      add(
        _ReviewMilestone(
          moveIndex: _analysis.length - 1,
          eyebrow: 'DESFECHO',
          title: 'Posição final',
          description: 'Revê como a história da partida terminou.',
          icon: Icons.flag_rounded,
          color: emberOrange,
        ),
      );
    }

    final result = milestones.values.toList()
      ..sort((a, b) => a.moveIndex.compareTo(b.moveIndex));
    return result;
  }

  bool _isEndgame(String fen) {
    final board = fen.split(' ').first;
    var pieces = 0;
    var officers = 0;
    for (final rune in board.runes) {
      final value = String.fromCharCode(rune).toLowerCase();
      if (!'kqrbnp'.contains(value)) continue;
      pieces++;
      if (value != 'k' && value != 'p') officers++;
    }
    return pieces <= 12 || officers <= 4;
  }

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = _analysis.isNotEmpty;
    final selected = hasAnalysis ? _analysis[_selectedIndex] : null;
    final fen = selected?.move.afterFen ?? widget.moves.first.afterFen;
    final position = chesslib.Chess.fromFEN(fen);
    final milestones = _running ? const <_ReviewMilestone>[] : _buildMilestones();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Revisão da partida', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: AppBackground(
        darken: .68,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
            children: [
              if (_running) ...[
                Row(
                  children: [
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Analisando lance ${_analysis.length + 1} de ${widget.moves.length}…',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text('${((_analysis.length / widget.moves.length) * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 9),
                LinearProgressIndicator(value: _analysis.length / widget.moves.length),
                const SizedBox(height: 18),
              ],
              if (_error != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (!_running && _analysis.isNotEmpty) ...[
                _AccuracySummary(
                  whiteAccuracy: _accuracyFor(true),
                  blackAccuracy: _accuracyFor(false),
                  bestMoves: _analysis.where((item) => item.quality == MoveQuality.best).length,
                  mistakes: _analysis
                      .where((item) =>
                          item.quality == MoveQuality.mistake ||
                          item.quality == MoveQuality.blunder)
                      .length,
                ),
                const SizedBox(height: 14),
              ],
              if (milestones.isNotEmpty) ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Marcos da partida',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${milestones.length} momentos',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 137,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: milestones.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 9),
                    itemBuilder: (context, index) {
                      final milestone = milestones[index];
                      return _MilestoneCard(
                        milestone: milestone,
                        selected: milestone.moveIndex == _selectedIndex,
                        onTap: () => setState(
                          () => _selectedIndex = milestone.moveIndex,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _AdvantageMeter(scoreWhite: selected?.scoreAfterWhite ?? 0),
              const SizedBox(height: 10),
              ChessBoard(
                game: position,
                paletteId: context.app.boardTheme,
                pieceSetId: context.app.pieceSet,
                flipped: widget.versusBot ? !widget.humanIsWhite : false,
                lastFrom: selected?.move.from,
                lastTo: selected?.move.to,
                onSquareTap: null,
              ),
              const SizedBox(height: 12),
              if (selected != null)
                _MoveReviewCard(
                  index: _selectedIndex,
                  analysis: selected,
                  formatUci: _formatUci,
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('O Stockfish está preparando a primeira avaliação…'),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedIndex > 0
                          ? () => setState(() => _selectedIndex--)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedIndex + 1 < _analysis.length
                          ? () => setState(() => _selectedIndex++)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Próximo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Todos os lances', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (var index = 0; index < _analysis.length; index++)
                        _MoveChip(
                          index: index,
                          move: _analysis[index],
                          selected: index == _selectedIndex,
                          onTap: () => setState(() => _selectedIndex = index),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _accuracyFor(bool white) {
    final sideMoves = _analysis.where((item) => item.move.whiteMoved == white).toList();
    if (sideMoves.isEmpty) return 100;
    final averageLoss = sideMoves.fold<int>(0, (sum, item) => sum + item.lossCp) /
        sideMoves.length;
    return (100 * math.exp(-averageLoss / 185)).clamp(0, 100).toDouble();
  }
}

class _ReviewMilestone {
  const _ReviewMilestone({
    required this.moveIndex,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final int moveIndex;
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.selected,
    required this.onTap,
  });

  final _ReviewMilestone milestone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        width: 205,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? milestone.color.withValues(alpha: .18)
              : const Color(0xD9251F1B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? milestone.color : Colors.white10,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: milestone.color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(milestone.icon, color: milestone.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${milestone.eyebrow} · ${milestone.moveIndex ~/ 2 + 1}${milestone.moveIndex.isEven ? '.' : '…'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: milestone.color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .55,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    milestone.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvantageMeter extends StatelessWidget {
  const _AdvantageMeter({required this.scoreWhite});

  final int scoreWhite;

  @override
  Widget build(BuildContext context) {
    final capped = scoreWhite.clamp(-1200, 1200).toDouble();
    final normalized = .5 + (capped / 1200) * .46;
    final label = scoreWhite.abs() >= 90000
        ? (scoreWhite > 0 ? 'Mate para brancas' : 'Mate para pretas')
        : '${scoreWhite >= 0 ? '+' : ''}${(scoreWhite / 100).toStringAsFixed(1)}';
    return Column(
      children: [
        Row(
          children: [
            const Text('Pretas', style: TextStyle(color: Colors.white54, fontSize: 11)),
            const Spacer(),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            const Spacer(),
            const Text('Brancas', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: ((1 - normalized) * 1000)
                      .round()
                      .clamp(1, 999)
                      .toInt(),
                  child: const ColoredBox(color: Color(0xFF181411)),
                ),
                Expanded(
                  flex: (normalized * 1000).round().clamp(1, 999).toInt(),
                  child: const ColoredBox(color: Color(0xFFF4EEE8)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MoveReviewCard extends StatelessWidget {
  const _MoveReviewCard({
    required this.index,
    required this.analysis,
    required this.formatUci,
  });

  final int index;
  final AnalyzedMove analysis;
  final String Function(String) formatUci;

  @override
  Widget build(BuildContext context) {
    final color = _qualityColor(analysis.quality);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
                  alignment: Alignment.center,
                  child: Text(
                    analysis.quality.symbol,
                    style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index ~/ 2 + 1}${index.isEven ? '.' : '…'} ${analysis.move.san}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        analysis.quality.label,
                        style: TextStyle(color: color, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(analysis.explanation, style: const TextStyle(color: Colors.white70, height: 1.35)),
            if (analysis.bestMove != null && analysis.quality != MoveQuality.best) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: emberOrange.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  'Linha sugerida: ${formatUci(analysis.bestMove!)}',
                  style: const TextStyle(color: emberOrange, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccuracySummary extends StatelessWidget {
  const _AccuracySummary({
    required this.whiteAccuracy,
    required this.blackAccuracy,
    required this.bestMoves,
    required this.mistakes,
  });

  final double whiteAccuracy;
  final double blackAccuracy;
  final int bestMoves;
  final int mistakes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _AccuracyValue(label: 'Brancas', value: whiteAccuracy, icon: '♔')),
                const SizedBox(width: 10),
                Expanded(child: _AccuracyValue(label: 'Pretas', value: blackAccuracy, icon: '♚')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$bestMoves melhores lances · $mistakes erros importantes',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccuracyValue extends StatelessWidget {
  const _AccuracyValue({required this.label, required this.value, required this.icon});

  final String label;
  final double value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 27)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${value.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({required this.index, required this.move, required this.selected, required this.onTap});

  final int index;
  final AnalyzedMove move;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _qualityColor(move.quality);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .25) : Colors.white.withValues(alpha: .04),
          border: Border.all(color: selected ? color : Colors.transparent),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          '${index ~/ 2 + 1}${index.isEven ? '.' : '…'} ${move.move.san} ${move.quality.symbol}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.white70),
        ),
      ),
    );
  }
}

Color _qualityColor(MoveQuality quality) => switch (quality) {
      MoveQuality.best => const Color(0xFF71D99B),
      MoveQuality.excellent => const Color(0xFF8BC8FF),
      MoveQuality.good => const Color(0xFFB9C78A),
      MoveQuality.inaccuracy => const Color(0xFFFFCB69),
      MoveQuality.mistake => const Color(0xFFFF9669),
      MoveQuality.blunder => const Color(0xFFFF5E68),
    };
