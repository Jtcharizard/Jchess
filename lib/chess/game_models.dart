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

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'humanIsWhite': humanIsWhite,
        'botLevel': botLevel,
        'botId': botId,
      };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['botLevel'];
    final parsedLevel = rawLevel is num ? rawLevel.toInt() : 0;
    return GameConfig(
      mode: json['mode'] == GameMode.local.name
          ? GameMode.local
          : GameMode.bot,
      humanIsWhite: json['humanIsWhite'] as bool? ?? true,
      botLevel: parsedLevel.clamp(0, 20).toInt(),
      botId: json['botId'] as String? ?? 'ravi',
    );
  }
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

  Map<String, dynamic> toJson() => {
        'beforeFen': beforeFen,
        'afterFen': afterFen,
        'from': from,
        'to': to,
        'uci': uci,
        'san': san,
        'whiteMoved': whiteMoved,
      };

  factory PlayedMove.fromJson(Map<String, dynamic> json) => PlayedMove(
        beforeFen: json['beforeFen'] as String,
        afterFen: json['afterFen'] as String,
        from: json['from'] as String,
        to: json['to'] as String,
        uci: json['uci'] as String,
        san: json['san'] as String,
        whiteMoved: json['whiteMoved'] as bool,
      );
}

class SavedGame {
  const SavedGame({
    required this.config,
    required this.moves,
    required this.savedAt,
  });

  final GameConfig config;
  final List<PlayedMove> moves;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'config': config.toJson(),
        'moves': moves.map((move) => move.toJson()).toList(),
        'savedAt': savedAt.toUtc().toIso8601String(),
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    final rawMoves = json['moves'] as List<dynamic>? ?? const [];
    return SavedGame(
      config: GameConfig.fromJson(
        Map<String, dynamic>.from(json['config'] as Map),
      ),
      moves: rawMoves
          .whereType<Map>()
          .map((move) => PlayedMove.fromJson(Map<String, dynamic>.from(move)))
          .toList(growable: false),
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
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
