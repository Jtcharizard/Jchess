import 'game_models.dart';

class GameplaySummary {
  const GameplaySummary({
    required this.fingerprint,
    required this.analyzedMoves,
    required this.bestMoves,
    required this.excellentMoves,
    required this.goodMoves,
    required this.inaccuracies,
    required this.mistakes,
    required this.blunders,
    required this.queenErrors,
    required this.castled,
    required this.openingPoints,
    required this.openingMoves,
    required this.middlegamePoints,
    required this.middlegameMoves,
    required this.endgamePoints,
    required this.endgameMoves,
  });

  final String fingerprint;
  final int analyzedMoves;
  final int bestMoves;
  final int excellentMoves;
  final int goodMoves;
  final int inaccuracies;
  final int mistakes;
  final int blunders;
  final int queenErrors;
  final bool castled;
  final int openingPoints;
  final int openingMoves;
  final int middlegamePoints;
  final int middlegameMoves;
  final int endgamePoints;
  final int endgameMoves;
}

class PhasePerformance {
  const PhasePerformance({
    required this.label,
    required this.points,
    required this.moves,
  });

  final String label;
  final int points;
  final int moves;

  double get score => moves == 0 ? 0 : points / moves;
}

class GameplayProfile {
  const GameplayProfile({
    this.analyzedGames = 0,
    this.analyzedMoves = 0,
    this.bestMoves = 0,
    this.excellentMoves = 0,
    this.goodMoves = 0,
    this.inaccuracies = 0,
    this.mistakes = 0,
    this.blunders = 0,
    this.queenErrors = 0,
    this.castledGames = 0,
    this.openingPoints = 0,
    this.openingMoves = 0,
    this.middlegamePoints = 0,
    this.middlegameMoves = 0,
    this.endgamePoints = 0,
    this.endgameMoves = 0,
  });

  final int analyzedGames;
  final int analyzedMoves;
  final int bestMoves;
  final int excellentMoves;
  final int goodMoves;
  final int inaccuracies;
  final int mistakes;
  final int blunders;
  final int queenErrors;
  final int castledGames;
  final int openingPoints;
  final int openingMoves;
  final int middlegamePoints;
  final int middlegameMoves;
  final int endgamePoints;
  final int endgameMoves;

  double get accuracy {
    if (analyzedMoves == 0) return 0;
    final points = bestMoves * 100 +
        excellentMoves * 90 +
        goodMoves * 75 +
        inaccuracies * 45 +
        mistakes * 20;
    return points / analyzedMoves;
  }

  double get castlingRate =>
      analyzedGames == 0 ? 0 : castledGames / analyzedGames;

  PhasePerformance? get strongestPhase {
    final phases = <PhasePerformance>[
      PhasePerformance(
        label: 'Abertura',
        points: openingPoints,
        moves: openingMoves,
      ),
      PhasePerformance(
        label: 'Meio-jogo',
        points: middlegamePoints,
        moves: middlegameMoves,
      ),
      PhasePerformance(
        label: 'Final',
        points: endgamePoints,
        moves: endgameMoves,
      ),
    ].where((phase) => phase.moves > 0).toList();
    if (phases.isEmpty) return null;
    phases.sort((a, b) => b.score.compareTo(a.score));
    return phases.first;
  }

  GameplayProfile merge(GameplaySummary summary) => GameplayProfile(
        analyzedGames: analyzedGames + 1,
        analyzedMoves: analyzedMoves + summary.analyzedMoves,
        bestMoves: bestMoves + summary.bestMoves,
        excellentMoves: excellentMoves + summary.excellentMoves,
        goodMoves: goodMoves + summary.goodMoves,
        inaccuracies: inaccuracies + summary.inaccuracies,
        mistakes: mistakes + summary.mistakes,
        blunders: blunders + summary.blunders,
        queenErrors: queenErrors + summary.queenErrors,
        castledGames: castledGames + (summary.castled ? 1 : 0),
        openingPoints: openingPoints + summary.openingPoints,
        openingMoves: openingMoves + summary.openingMoves,
        middlegamePoints: middlegamePoints + summary.middlegamePoints,
        middlegameMoves: middlegameMoves + summary.middlegameMoves,
        endgamePoints: endgamePoints + summary.endgamePoints,
        endgameMoves: endgameMoves + summary.endgameMoves,
      );

  Map<String, dynamic> toJson() => {
        'analyzedGames': analyzedGames,
        'analyzedMoves': analyzedMoves,
        'bestMoves': bestMoves,
        'excellentMoves': excellentMoves,
        'goodMoves': goodMoves,
        'inaccuracies': inaccuracies,
        'mistakes': mistakes,
        'blunders': blunders,
        'queenErrors': queenErrors,
        'castledGames': castledGames,
        'openingPoints': openingPoints,
        'openingMoves': openingMoves,
        'middlegamePoints': middlegamePoints,
        'middlegameMoves': middlegameMoves,
        'endgamePoints': endgamePoints,
        'endgameMoves': endgameMoves,
      };

  factory GameplayProfile.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;
    return GameplayProfile(
      analyzedGames: read('analyzedGames'),
      analyzedMoves: read('analyzedMoves'),
      bestMoves: read('bestMoves'),
      excellentMoves: read('excellentMoves'),
      goodMoves: read('goodMoves'),
      inaccuracies: read('inaccuracies'),
      mistakes: read('mistakes'),
      blunders: read('blunders'),
      queenErrors: read('queenErrors'),
      castledGames: read('castledGames'),
      openingPoints: read('openingPoints'),
      openingMoves: read('openingMoves'),
      middlegamePoints: read('middlegamePoints'),
      middlegameMoves: read('middlegameMoves'),
      endgamePoints: read('endgamePoints'),
      endgameMoves: read('endgameMoves'),
    );
  }
}

GameplaySummary summarizeGameplay({
  required List<AnalyzedMove> analysis,
  required bool humanIsWhite,
}) {
  var bestMoves = 0;
  var excellentMoves = 0;
  var goodMoves = 0;
  var inaccuracies = 0;
  var mistakes = 0;
  var blunders = 0;
  var queenErrors = 0;
  var castled = false;
  var openingPoints = 0;
  var openingMoves = 0;
  var middlegamePoints = 0;
  var middlegameMoves = 0;
  var endgamePoints = 0;
  var endgameMoves = 0;

  for (var index = 0; index < analysis.length; index++) {
    final item = analysis[index];
    if (item.move.whiteMoved != humanIsWhite) continue;

    switch (item.quality) {
      case MoveQuality.best:
        bestMoves++;
      case MoveQuality.excellent:
        excellentMoves++;
      case MoveQuality.good:
        goodMoves++;
      case MoveQuality.inaccuracy:
        inaccuracies++;
      case MoveQuality.mistake:
        mistakes++;
      case MoveQuality.blunder:
        blunders++;
    }

    final points = _qualityPoints(item.quality);
    if (index < 20) {
      openingPoints += points;
      openingMoves++;
    } else if (_isEndgame(item.move.beforeFen)) {
      endgamePoints += points;
      endgameMoves++;
    } else {
      middlegamePoints += points;
      middlegameMoves++;
    }

    final movedPiece = _pieceAt(item.move.beforeFen, item.move.from);
    if (movedPiece?.toLowerCase() == 'q' &&
        (item.quality == MoveQuality.mistake ||
            item.quality == MoveQuality.blunder)) {
      queenErrors++;
    }
    if (item.move.san.startsWith('O-O') || item.move.san.startsWith('0-0')) {
      castled = true;
    }
  }

  final playerMoves =
      bestMoves + excellentMoves + goodMoves + inaccuracies + mistakes + blunders;
  return GameplaySummary(
    fingerprint: _fingerprint(analysis, humanIsWhite),
    analyzedMoves: playerMoves,
    bestMoves: bestMoves,
    excellentMoves: excellentMoves,
    goodMoves: goodMoves,
    inaccuracies: inaccuracies,
    mistakes: mistakes,
    blunders: blunders,
    queenErrors: queenErrors,
    castled: castled,
    openingPoints: openingPoints,
    openingMoves: openingMoves,
    middlegamePoints: middlegamePoints,
    middlegameMoves: middlegameMoves,
    endgamePoints: endgamePoints,
    endgameMoves: endgameMoves,
  );
}

int _qualityPoints(MoveQuality quality) => switch (quality) {
      MoveQuality.best => 100,
      MoveQuality.excellent => 90,
      MoveQuality.good => 75,
      MoveQuality.inaccuracy => 45,
      MoveQuality.mistake => 20,
      MoveQuality.blunder => 0,
    };

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

String? _pieceAt(String fen, String square) {
  if (square.length != 2) return null;
  final fileTarget = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
  final rank = int.tryParse(square[1]);
  if (fileTarget < 0 || fileTarget > 7 || rank == null || rank < 1 || rank > 8) {
    return null;
  }
  final rows = fen.split(' ').first.split('/');
  if (rows.length != 8) return null;
  final row = rows[8 - rank];
  var file = 0;
  for (final rune in row.runes) {
    final value = String.fromCharCode(rune);
    final empty = int.tryParse(value);
    if (empty != null) {
      file += empty;
      continue;
    }
    if (file == fileTarget) return value;
    file++;
  }
  return null;
}

String _fingerprint(List<AnalyzedMove> analysis, bool humanIsWhite) {
  final value = '${humanIsWhite ? 'w' : 'b'}:${analysis.map((item) => item.move.uci).join(',')}';
  var hash = 0x811C9DC5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
