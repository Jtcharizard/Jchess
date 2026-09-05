enum GameMode { bot, local }

enum SideChoice { white, black, random }

class GameConfig {
  const GameConfig({
    required this.mode,
    required this.humanIsWhite,
    required this.botLevel,
    required this.botId,
  });

  final GameMode mode;
  final bool humanIsWhite;
  final int botLevel;
  final String botId;
}

class PlayedMove {
  const PlayedMove({
    required this.beforeFen,
    required this.afterFen,
    required this.from,
    required this.to,
    required this.uci,
    required this.san,
    required this.whiteMoved,
  });

  final String beforeFen;
  final String afterFen;
  final String from;
  final String to;
  final String uci;
  final String san;
  final bool whiteMoved;
}

class EngineEvaluation {
  const EngineEvaluation({
    required this.bestMove,
    required this.scoreCp,
    required this.depth,
    required this.principalVariation,
    this.mate,
  });

  final String? bestMove;
  final int scoreCp;
  final int depth;
  final List<String> principalVariation;
  final int? mate;

  double get pawns => scoreCp / 100;
}

enum MoveQuality {
  best,
  excellent,
  good,
  inaccuracy,
  mistake,
  blunder,
}

class AnalyzedMove {
  const AnalyzedMove({
    required this.move,
    required this.quality,
    required this.lossCp,
    required this.scoreAfterWhite,
    required this.bestMove,
    required this.explanation,
  });

  final PlayedMove move;
  final MoveQuality quality;
  final int lossCp;
  final int scoreAfterWhite;
  final String? bestMove;
  final String explanation;
}

extension MoveQualityText on MoveQuality {
  String get label => switch (this) {
        MoveQuality.best => 'Melhor lance',
        MoveQuality.excellent => 'Excelente',
        MoveQuality.good => 'Boa',
        MoveQuality.inaccuracy => 'Imprecisão',
        MoveQuality.mistake => 'Erro',
        MoveQuality.blunder => 'Erro grave',
      };

  String get symbol => switch (this) {
        MoveQuality.best => '★',
        MoveQuality.excellent => '✓',
        MoveQuality.good => '●',
        MoveQuality.inaccuracy => '?!',
        MoveQuality.mistake => '?',
        MoveQuality.blunder => '??',
      };
}
