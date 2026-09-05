import 'dart:async';

import 'package:stockfish/stockfish.dart';

import 'game_models.dart';

class StockfishService {
  StockfishService() {
    _engine = Stockfish();
    _stdoutSubscription = _engine.stdout.listen(_handleLine);
    _engine.state.addListener(_handleState);
    _handleState();
  }

  late final Stockfish _engine;
  late final StreamSubscription<String> _stdoutSubscription;
  final Completer<void> _readyCompleter = Completer<void>();
  Future<void> _queue = Future<void>.value();
  Completer<EngineEvaluation>? _activeRequest;
  int _latestScore = 0;
  int? _latestMate;
  int _latestDepth = 0;
  List<String> _latestPv = const [];
  bool _disposed = false;

  bool get isReady => _engine.state.value == StockfishState.ready;

  void _handleState() {
    if (isReady && !_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  Future<EngineEvaluation> analyze(
    String fen, {
    int skillLevel = 10,
    int moveTimeMs = 450,
  }) {
    final result = Completer<EngineEvaluation>();

    _queue = _queue.then((_) async {
      if (_disposed) {
        throw StateError('O motor de xadrez já foi encerrado.');
      }
      try {
        final evaluation = await _runAnalysis(
          fen,
          skillLevel: skillLevel,
          moveTimeMs: moveTimeMs,
        );
        if (!result.isCompleted) result.complete(evaluation);
      } catch (error, stackTrace) {
        if (!result.isCompleted) result.completeError(error, stackTrace);
      }
    });

    return result.future;
  }

  Future<String?> bestMove(
    String fen, {
    required int skillLevel,
    int moveTimeMs = 550,
  }) async {
    final evaluation = await analyze(
      fen,
      skillLevel: skillLevel,
      moveTimeMs: moveTimeMs,
    );
    return evaluation.bestMove;
  }

  Future<EngineEvaluation> _runAnalysis(
    String fen, {
    required int skillLevel,
    required int moveTimeMs,
  }) async {
    await _readyCompleter.future.timeout(const Duration(seconds: 12));
    _latestScore = 0;
    _latestMate = null;
    _latestDepth = 0;
    _latestPv = const [];

    final completer = Completer<EngineEvaluation>();
    _activeRequest = completer;
    _engine.stdin = 'stop';
    _engine.stdin =
        'setoption name Skill Level value ${skillLevel.clamp(0, 20)}';
    _engine.stdin = 'position fen $fen';
    _engine.stdin = 'go movetime ${moveTimeMs.clamp(80, 10000)}';

    return completer.future.timeout(
      Duration(milliseconds: moveTimeMs + 8000),
      onTimeout: () {
        _engine.stdin = 'stop';
        _activeRequest = null;
        return EngineEvaluation(
          bestMove: _latestPv.firstOrNull,
          scoreCp: _latestScore,
          depth: _latestDepth,
          principalVariation: _latestPv,
          mate: _latestMate,
        );
      },
    );
  }

  void _handleLine(String line) {
    if (line.startsWith('info ')) {
      final depthMatch = RegExp(r'\bdepth (\d+)').firstMatch(line);
      final scoreMatch = RegExp(r'\bscore cp (-?\d+)').firstMatch(line);
      final mateMatch = RegExp(r'\bscore mate (-?\d+)').firstMatch(line);
      final pvMatch = RegExp(r'\bpv (.+)$').firstMatch(line);

      if (depthMatch != null) {
        _latestDepth = int.tryParse(depthMatch.group(1)!) ?? _latestDepth;
      }
      if (scoreMatch != null) {
        _latestScore = int.tryParse(scoreMatch.group(1)!) ?? _latestScore;
        _latestMate = null;
      } else if (mateMatch != null) {
        _latestMate = int.tryParse(mateMatch.group(1)!);
        _latestScore = (_latestMate ?? 0) >= 0 ? 100000 : -100000;
      }
      if (pvMatch != null) {
        _latestPv = pvMatch.group(1)!.trim().split(RegExp(r'\s+'));
      }
      return;
    }

    if (!line.startsWith('bestmove ')) return;
    final parts = line.split(RegExp(r'\s+'));
    final rawMove = parts.length > 1 ? parts[1] : '(none)';
    final move = rawMove == '(none)' ? null : rawMove;
    final request = _activeRequest;
    _activeRequest = null;
    if (request != null && !request.isCompleted) {
      request.complete(
        EngineEvaluation(
          bestMove: move,
          scoreCp: _latestScore,
          depth: _latestDepth,
          principalVariation: _latestPv,
          mate: _latestMate,
        ),
      );
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _engine.state.removeListener(_handleState);
    _stdoutSubscription.cancel();
    _engine.dispose();
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
