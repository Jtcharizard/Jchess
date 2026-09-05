import 'dart:async';

import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../chess/game_models.dart';
import '../chess/stockfish_service.dart';
import '../widgets/app_background.dart';
import '../widgets/chess_board.dart';
import 'analysis_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.config, super.key});

  final GameConfig config;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final chesslib.Chess _game = chesslib.Chess();
  final StockfishService _engine = StockfishService();
  final List<PlayedMove> _moves = [];

  String? _selectedSquare;
  List<Map<String, dynamic>> _selectedMoves = [];
  String? _lastFrom;
  String? _lastTo;
  String? _hintFrom;
  String? _hintTo;
  bool _thinking = false;
  bool _finished = false;
  bool _resultRecorded = false;
  late bool _flipped;
  String _status = 'Brancas começam';

  @override
  void initState() {
    super.initState();
    _flipped = widget.config.mode == GameMode.bot
        ? !widget.config.humanIsWhite
        : false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isBotTurn) _playBotMove();
    });
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  bool get _whiteToMove => _game.turn == chesslib.Color.WHITE;

  bool get _isBotTurn =>
      widget.config.mode == GameMode.bot &&
      _whiteToMove != widget.config.humanIsWhite &&
      !_finished;

  bool get _canPlayerMove =>
      !_thinking && !_finished &&
      (widget.config.mode == GameMode.local || !_isBotTurn);

  @override
  Widget build(BuildContext context) {
    final boardTheme = context.app.boardTheme;
    final topIsWhite = _flipped;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton.filledTonal(
          tooltip: 'Voltar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.config.mode == GameMode.bot ? 'Contra o bot' : 'Partida local',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Copiar PGN',
            onPressed: _moves.isEmpty ? null : _copyPgn,
            icon: const Icon(Icons.copy_all_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        darken: .56,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardWidth = constraints.maxWidth.clamp(0, 620).toDouble();
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      children: [
                        _PlayerStrip(
                          isWhite: topIsWhite,
                          name: _playerName(topIsWhite),
                          subtitle: _playerSubtitle(topIsWhite),
                          active: _whiteToMove == topIsWhite && !_finished,
                          thinking: _thinking && _isBotColor(topIsWhite),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: boardWidth,
                          child: ChessBoard(
                            game: _game,
                            paletteId: boardTheme,
                            flipped: _flipped,
                            selectedSquare: _selectedSquare,
                            legalTargets: _selectedMoves
                                .map((move) => move['to'] as String)
                                .toSet(),
                            lastFrom: _lastFrom,
                            lastTo: _lastTo,
                            hintFrom: _hintFrom,
                            hintTo: _hintTo,
                            onSquareTap: _canPlayerMove ? _onSquareTap : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PlayerStrip(
                          isWhite: !topIsWhite,
                          name: _playerName(!topIsWhite),
                          subtitle: _playerSubtitle(!topIsWhite),
                          active: _whiteToMove != topIsWhite && !_finished,
                          thinking: _thinking && _isBotColor(!topIsWhite),
                        ),
                        const SizedBox(height: 12),
                        _StatusCard(status: _status, inCheck: _isInCheck),
                        const SizedBox(height: 10),
                        _MoveHistory(moves: _moves),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.undo_rounded,
                                label: 'Desfazer',
                                onPressed: _moves.isEmpty || _thinking ? null : _undo,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.lightbulb_rounded,
                                label: 'Dica',
                                onPressed: !_canPlayerMove ? null : _requestHint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.rotate_90_degrees_ccw_rounded,
                                label: 'Girar',
                                onPressed: () => setState(() => _flipped = !_flipped),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _moves.isEmpty || _thinking ? null : _openAnalysis,
                            icon: const Icon(Icons.analytics_rounded),
                            label: const Text('Analisar partida'),
                          ),
                        ),
                        if (!_finished) ...[
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _thinking ? null : _resign,
                            icon: const Icon(Icons.flag_rounded),
                            label: const Text('Abandonar partida'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _isInCheck {
    try {
      return _game.in_check;
    } catch (_) {
      return false;
    }
  }

  String _playerName(bool white) {
    if (widget.config.mode == GameMode.local) {
      return white ? 'Jogador das brancas' : 'Jogador das pretas';
    }
    return white == widget.config.humanIsWhite ? 'Tu' : 'JChess Bot';
  }

  String _playerSubtitle(bool white) {
    if (widget.config.mode == GameMode.bot && _isBotColor(white)) {
      return 'Stockfish · nível ${widget.config.botLevel}';
    }
    return white ? 'Peças brancas' : 'Peças pretas';
  }

  bool _isBotColor(bool white) =>
      widget.config.mode == GameMode.bot && white != widget.config.humanIsWhite;

  void _onSquareTap(String square) {
    if (!_canPlayerMove) return;
    final piece = _game.get(square);
    final ownPiece = piece != null && piece.color == _game.turn;

    if (_selectedSquare != null) {
      final possible = _selectedMoves.where((move) => move['to'] == square).toList();
      if (possible.isNotEmpty) {
        _attemptMove(_selectedSquare!, square, possible);
        return;
      }
    }

    if (!ownPiece) {
      setState(() {
        _selectedSquare = null;
        _selectedMoves = [];
      });
      return;
    }

    final moves = _legalMovesFrom(square);
    setState(() {
      _selectedSquare = square;
      _selectedMoves = moves;
      _hintFrom = null;
      _hintTo = null;
    });
  }

  List<Map<String, dynamic>> _legalMovesFrom(String square) {
    final raw = _game.moves({'square': square, 'verbose': true});
    return raw
        .whereType<Map>()
        .map((move) => Map<String, dynamic>.from(move))
        .toList();
  }

  Future<void> _attemptMove(
    String from,
    String to,
    List<Map<String, dynamic>> candidates,
  ) async {
    String promotion = 'q';
    final promotionMove = candidates.any(
      (move) => (move['flags'] as String?)?.contains('p') ?? false,
    );
    if (promotionMove) {
      final selected = await _choosePromotion();
      if (selected == null || !mounted) return;
      promotion = selected;
    }
    _applyMove(from, to, promotion: promotion);
  }

  Future<String?> _choosePromotion() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover peão'),
        content: const Text('Escolhe a nova peça:'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          for (final option in const [
            ('q', '♛', 'Dama'),
            ('r', '♜', 'Torre'),
            ('b', '♝', 'Bispo'),
            ('n', '♞', 'Cavalo'),
          ])
            IconButton(
              tooltip: option.$3,
              onPressed: () => Navigator.pop(context, option.$1),
              icon: Text(option.$2, style: const TextStyle(fontSize: 34)),
            ),
        ],
      ),
    );
  }

  bool _applyMove(String from, String to, {String promotion = 'q'}) {
    final beforeFen = _game.fen;
    final whiteMoved = _whiteToMove;
    final candidates = _game
        .moves({'square': from, 'verbose': true})
        .whereType<Map>()
        .map((move) => Map<String, dynamic>.from(move))
        .where((move) => move['to'] == to)
        .toList();
    if (candidates.isEmpty) return false;

    var candidate = candidates.first;
    if (candidates.length > 1) {
      candidate = candidates.firstWhere(
        (move) => (move['san'] as String).contains('=${promotion.toUpperCase()}'),
        orElse: () => candidates.first,
      );
    }
    final san = candidate['san'] as String? ?? '$from$to';
    final success = _game.move({
      'from': from,
      'to': to,
      'promotion': promotion,
    });
    if (!success) return false;

    final uci = '$from$to${candidates.length > 1 ? promotion : ''}';
    _moves.add(
      PlayedMove(
        beforeFen: beforeFen,
        afterFen: _game.fen,
        from: from,
        to: to,
        uci: uci,
        san: san,
        whiteMoved: whiteMoved,
      ),
    );
    _lastFrom = from;
    _lastTo = to;
    _selectedSquare = null;
    _selectedMoves = [];
    _hintFrom = null;
    _hintTo = null;
    _updateStatus();
    setState(() {});

    if (!_finished && _isBotTurn) {
      Future<void>.delayed(const Duration(milliseconds: 260), _playBotMove);
    }
    return true;
  }

  Future<void> _playBotMove() async {
    if (!_isBotTurn || _thinking || !mounted) return;
    setState(() {
      _thinking = true;
      _status = 'O bot está pensando…';
    });

    try {
      final move = await _engine.bestMove(
        _game.fen,
        skillLevel: widget.config.botLevel,
        moveTimeMs: 280 + widget.config.botLevel * 45,
      );
      if (!mounted || move == null || move.length < 4) return;
      final from = move.substring(0, 2);
      final to = move.substring(2, 4);
      final promotion = move.length > 4 ? move.substring(4, 5) : 'q';
      _applyMove(from, to, promotion: promotion);
    } catch (_) {
      if (mounted) {
        _showMessage('O Stockfish demorou para responder. Tenta de novo.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _thinking = false;
          if (!_finished) _updateStatus();
        });
      }
    }
  }

  Future<void> _requestHint() async {
    if (!_canPlayerMove) return;
    setState(() {
      _thinking = true;
      _status = 'Procurando uma boa ideia…';
    });
    try {
      final move = await _engine.bestMove(
        _game.fen,
        skillLevel: 18,
        moveTimeMs: 700,
      );
      if (!mounted || move == null || move.length < 4) return;
      setState(() {
        _hintFrom = move.substring(0, 2);
        _hintTo = move.substring(2, 4);
        _status = 'Dica: olha com carinho para ${_hintFrom!} → ${_hintTo!}.';
      });
    } catch (_) {
      if (mounted) _showMessage('Não consegui calcular a dica agora.');
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }

  void _undo() {
    if (_moves.isEmpty || _thinking) return;
    var amount = 1;
    if (widget.config.mode == GameMode.bot && _moves.length >= 2 && !_isBotTurn) {
      amount = 2;
    }

    for (var index = 0; index < amount && _moves.isNotEmpty; index++) {
      _game.undo();
      _moves.removeLast();
    }
    final last = _moves.isEmpty ? null : _moves.last;
    setState(() {
      _lastFrom = last?.from;
      _lastTo = last?.to;
      _selectedSquare = null;
      _selectedMoves = [];
      _hintFrom = null;
      _hintTo = null;
      _finished = false;
      _updateStatus();
    });
  }

  void _updateStatus() {
    if (_game.in_checkmate) {
      final whiteWon = !_whiteToMove;
      _finish(
        whiteWon ? 'Xeque-mate! Brancas venceram.' : 'Xeque-mate! Pretas venceram.',
        winnerIsWhite: whiteWon,
      );
      return;
    }
    if (_game.in_draw) {
      _finish('Empate. Ninguém leva o rei para casa.');
      return;
    }
    final turn = _whiteToMove ? 'Brancas' : 'Pretas';
    _status = _isInCheck ? 'Xeque! Vez das $turn.' : 'Vez das $turn.';
  }

  void _finish(String message, {bool? winnerIsWhite}) {
    _finished = true;
    _status = message;
    if (_resultRecorded) return;
    _resultRecorded = true;

    if (widget.config.mode == GameMode.local) {
      unawaited(context.app.recordGame(GameResult.local));
    } else if (winnerIsWhite == null) {
      unawaited(context.app.recordGame(GameResult.draw));
    } else if (winnerIsWhite == widget.config.humanIsWhite) {
      unawaited(context.app.recordGame(GameResult.win));
    } else {
      unawaited(context.app.recordGame(GameResult.loss));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showResultSheet(message);
    });
  }

  Future<void> _resign() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonar partida?'),
        content: const Text('A partida termina, mas ainda dá para analisar os lances.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Abandonar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (widget.config.mode == GameMode.bot) {
      final winnerIsWhite = !widget.config.humanIsWhite;
      _finish('Partida abandonada.', winnerIsWhite: winnerIsWhite);
    } else {
      _finish('Partida encerrada pelos jogadores.');
    }
    setState(() {});
  }

  Future<void> _showResultSheet(String message) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF211B17),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('♛', style: TextStyle(fontSize: 50, color: emberOrange)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openAnalysis();
                  },
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text('Revisar meus lances'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAnalysis() async {
    if (_moves.isEmpty || _thinking) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          moves: List<PlayedMove>.unmodifiable(_moves),
          engine: _engine,
          humanIsWhite: widget.config.humanIsWhite,
          versusBot: widget.config.mode == GameMode.bot,
        ),
      ),
    );
  }

  Future<void> _copyPgn() async {
    await Clipboard.setData(ClipboardData(text: _game.pgn()));
    if (mounted) _showMessage('PGN copiado.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PlayerStrip extends StatelessWidget {
  const _PlayerStrip({
    required this.isWhite,
    required this.name,
    required this.subtitle,
    required this.active,
    required this.thinking,
  });

  final bool isWhite;
  final String name;
  final String subtitle;
  final bool active;
  final bool thinking;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xE63A2A20) : const Color(0xC9201A16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? emberOrange : Colors.white.withValues(alpha: .06),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isWhite ? const Color(0xFFF7EEE2) : const Color(0xFF17120F),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              isWhite ? '♔' : '♚',
              style: TextStyle(
                color: isWhite ? Colors.black87 : Colors.white,
                fontSize: 27,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          if (thinking)
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (active)
            const Icon(Icons.circle, size: 10, color: emberOrange),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.inCheck});

  final String status;
  final bool inCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: inCheck ? const Color(0xB34F1717) : const Color(0xC9201A16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            inCheck ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: inCheck ? Colors.redAccent : emberOrange,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(status, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MoveHistory extends StatelessWidget {
  const _MoveHistory({required this.moves});

  final List<PlayedMove> moves;

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text('Os lances vão aparecer aqui.', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        itemCount: moves.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, reversedIndex) {
          final index = moves.length - 1 - reversedIndex;
          final move = moves[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: index == moves.length - 1
                  ? emberOrange.withValues(alpha: .22)
                  : Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index ~/ 2 + 1}${index.isEven ? '.' : '…'} ${move.san}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        backgroundColor: const Color(0xB3201A16),
        side: BorderSide(color: Colors.white.withValues(alpha: .09)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
