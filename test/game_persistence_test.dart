import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/chess/game_models.dart';

void main() {
  test('partida salva preserva configuração, lances e momento', () {
    final savedAt = DateTime.utc(2026, 9, 5, 12, 30);
    final saved = SavedGame(
      config: const GameConfig(
        mode: GameMode.bot,
        humanIsWhite: false,
        botLevel: 10,
        botId: 'iris',
      ),
      moves: const [
        PlayedMove(
          beforeFen:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          afterFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
          from: 'e2',
          to: 'e4',
          uci: 'e2e4',
          san: 'e4',
          whiteMoved: true,
        ),
      ],
      savedAt: savedAt,
    );

    final restored = SavedGame.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(saved.toJson())) as Map),
    );

    expect(restored.config.mode, GameMode.bot);
    expect(restored.config.humanIsWhite, isFalse);
    expect(restored.config.botLevel, 10);
    expect(restored.config.botId, 'iris');
    expect(restored.moves, hasLength(1));
    expect(restored.moves.single.uci, 'e2e4');
    expect(restored.moves.single.afterFen, saved.moves.single.afterFen);
    expect(restored.savedAt, savedAt);
  });

  test('nível inválido é limitado ao intervalo do Stockfish', () {
    final config = GameConfig.fromJson({
      'mode': 'bot',
      'humanIsWhite': true,
      'botLevel': 99,
      'botId': 'nox',
    });

    expect(config.botLevel, 20);
  });
}
