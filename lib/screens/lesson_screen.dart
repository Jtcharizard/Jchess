import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../chess/lessons.dart';
import '../widgets/app_background.dart';
import '../widgets/chess_board.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({required this.index, super.key});

  final int index;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late ChessLesson _lesson;
  late chesslib.Chess _game;
  String? _selectedSquare;
  List<Map<String, dynamic>> _legalMoves = [];
  String? _lastFrom;
  String? _lastTo;
  String? _hintFrom;
  String? _hintTo;
  String? _feedback;
  bool _complete = false;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _lesson = lessonCatalog[widget.index];
    _game = chesslib.Chess.fromFEN(_lesson.fen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text('Lição ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: AppBackground(
        darken: .68,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 26),
            children: [
              Text(
                _lesson.category,
                style: const TextStyle(color: emberOrange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 5),
              Text(_lesson.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(_lesson.description, style: const TextStyle(color: Colors.white60, height: 1.35)),
              const SizedBox(height: 18),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _wrong ? const Color(0x994D1616) : const Color(0xD928211C),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _complete ? const Color(0xFF64D896) : emberOrange.withValues(alpha: .4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _complete ? Icons.check_circle_rounded : Icons.flag_rounded,
                      color: _complete ? const Color(0xFF64D896) : emberOrange,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _feedback ?? _lesson.instruction,
                        style: const TextStyle(fontWeight: FontWeight.w800, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ChessBoard(
                game: _game,
                paletteId: context.app.boardTheme,
                selectedSquare: _selectedSquare,
                legalTargets: _legalMoves.map((move) => move['to'] as String).toSet(),
                lastFrom: _lastFrom,
                lastTo: _lastTo,
                hintFrom: _hintFrom,
                hintTo: _hintTo,
                onSquareTap: _complete ? null : _onSquareTap,
              ),
              const SizedBox(height: 14),
              if (!_complete)
                OutlinedButton.icon(
                  onPressed: _showHint,
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: const Text('Me dá uma dica'),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _next,
                    icon: Icon(widget.index + 1 < lessonCatalog.length ? Icons.arrow_forward_rounded : Icons.emoji_events_rounded),
                    label: Text(widget.index + 1 < lessonCatalog.length ? 'Próxima lição' : 'Concluir trilha'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Fazer de novo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onSquareTap(String square) {
    final piece = _game.get(square);
    if (_selectedSquare != null) {
      final target = _legalMoves.any((move) => move['to'] == square);
      if (target) {
        _tryMove(_selectedSquare!, square);
        return;
      }
    }

    if (piece == null || piece.color != _game.turn) {
      setState(() {
        _selectedSquare = null;
        _legalMoves = [];
      });
      return;
    }

    final rawMoves = _game.moves({'square': square, 'verbose': true});
    setState(() {
      _selectedSquare = square;
      _legalMoves = rawMoves
          .whereType<Map>()
          .map((move) => Map<String, dynamic>.from(move))
          .toList();
      _wrong = false;
    });
  }

  void _tryMove(String from, String to) {
    final uci = '$from$to';
    if (!_lesson.acceptedMoves.contains(uci)) {
      setState(() {
        _wrong = true;
        _feedback = 'Esse lance é permitido, mas não resolve o desafio. Tenta outra ideia.';
        _selectedSquare = null;
        _legalMoves = [];
      });
      return;
    }

    final success = _game.move({'from': from, 'to': to, 'promotion': 'q'});
    if (!success) return;
    context.app.completeLesson(widget.index);
    setState(() {
      _complete = true;
      _wrong = false;
      _feedback = _lesson.success;
      _lastFrom = from;
      _lastTo = to;
      _selectedSquare = null;
      _legalMoves = [];
      _hintFrom = null;
      _hintTo = null;
    });
  }

  void _showHint() {
    final move = _lesson.acceptedMoves.first;
    setState(() {
      _feedback = _lesson.hint;
      _hintFrom = move.substring(0, 2);
      _hintTo = move.substring(2, 4);
      _wrong = false;
    });
  }

  void _reset() {
    setState(() {
      _game = chesslib.Chess.fromFEN(_lesson.fen);
      _complete = false;
      _wrong = false;
      _feedback = null;
      _selectedSquare = null;
      _legalMoves = [];
      _lastFrom = null;
      _lastTo = null;
      _hintFrom = null;
      _hintTo = null;
    });
  }

  void _next() {
    if (widget.index + 1 >= lessonCatalog.length) {
      Navigator.pop(context);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LessonScreen(index: widget.index + 1)),
    );
  }
}

