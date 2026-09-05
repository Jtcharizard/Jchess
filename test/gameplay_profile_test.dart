import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/app/app_controller.dart';
import 'package:jchess/chess/game_models.dart';
import 'package:jchess/chess/gameplay_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const initialFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  const castleFen = '4k3/8/8/8/8/8/8/4K2R w K - 0 1';
  const queenOfferBefore = '4k3/8/8/8/8/8/3Q4/4K3 w - - 0 1';
  const queenOfferAfter = '3Qk3/8/8/8/8/8/8/4K3 b - - 0 1';
  const queenCapturedAfter = '3k4/8/8/8/8/8/8/4K3 w - - 0 2';

  AnalyzedMove analyzed({
    required String from,
    required String to,
    required String san,
    required String beforeFen,
    String? afterFen,
    required bool whiteMoved,
    required MoveQuality quality,
  }) {
    return AnalyzedMove(
      move: PlayedMove(
        beforeFen: beforeFen,
        afterFen: afterFen ?? beforeFen,
        from: from,
        to: to,
        uci: '$from$to',
        san: san,
        whiteMoved: whiteMoved,
      ),
      quality: quality,
      lossCp: quality == MoveQuality.blunder ? 400 : 15,
      scoreAfterWhite: 0,
      bestMove: null,
      explanation: '',
    );
  }

  test('resume padrões apenas dos lances do jogador', () {
    final summary = summarizeGameplay(
      humanIsWhite: true,
      analysis: [
        analyzed(
          from: 'd1',
          to: 'h5',
          san: 'Qh5',
          beforeFen: initialFen,
          whiteMoved: true,
          quality: MoveQuality.blunder,
        ),
        analyzed(
          from: 'e7',
          to: 'e5',
          san: 'e5',
          beforeFen: initialFen,
          whiteMoved: false,
          quality: MoveQuality.mistake,
        ),
        analyzed(
          from: 'e1',
          to: 'g1',
          san: 'O-O',
          beforeFen: castleFen,
          whiteMoved: true,
          quality: MoveQuality.excellent,
        ),
      ],
    );

    expect(summary.analyzedMoves, 2);
    expect(summary.blunders, 1);
    expect(summary.mistakes, 0);
    expect(summary.excellentMoves, 1);
    expect(summary.queenErrors, 0);
    expect(summary.castled, isTrue);
    expect(summary.openingMoves, 2);
  });

  test('só marca erro de rainha quando ela é perdida na resposta', () {
    final summary = summarizeGameplay(
      humanIsWhite: true,
      analysis: [
        analyzed(
          from: 'd2',
          to: 'd8',
          san: 'Qd8+',
          beforeFen: queenOfferBefore,
          afterFen: queenOfferAfter,
          whiteMoved: true,
          quality: MoveQuality.blunder,
        ),
        analyzed(
          from: 'e8',
          to: 'd8',
          san: 'Kxd8',
          beforeFen: queenOfferAfter,
          afterFen: queenCapturedAfter,
          whiteMoved: false,
          quality: MoveQuality.best,
        ),
      ],
    );

    expect(summary.queenErrors, 1);
  });

  test('não contabiliza a mesma revisão duas vezes e persiste o perfil', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController();
    await controller.load();
    final summary = summarizeGameplay(
      humanIsWhite: true,
      analysis: [
        analyzed(
          from: 'd2',
          to: 'd8',
          san: 'Qd8+',
          beforeFen: queenOfferBefore,
          afterFen: queenOfferAfter,
          whiteMoved: true,
          quality: MoveQuality.blunder,
        ),
        analyzed(
          from: 'e8',
          to: 'd8',
          san: 'Kxd8',
          beforeFen: queenOfferAfter,
          afterFen: queenCapturedAfter,
          whiteMoved: false,
          quality: MoveQuality.best,
        ),
      ],
    );

    await controller.recordGameplayAnalysis(summary);
    await controller.recordGameplayAnalysis(summary);

    expect(controller.gameplayProfile.analyzedGames, 1);
    expect(controller.gameplayProfile.queenErrors, 1);

    final restored = AppController();
    await restored.load();
    expect(restored.gameplayProfile.analyzedGames, 1);
    expect(restored.gameplayProfile.blunders, 1);
    expect(restored.gameplayProfile.queenErrors, 1);
  });
}
