import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/app/app_controller.dart';
import 'package:jchess/chess/game_models.dart';
import 'package:jchess/main.dart';

void main() {
  testWidgets('abre a tela inicial do JChess', (tester) async {
    await tester.pumpWidget(JChessApp(controller: AppController()));
    await tester.pumpAndSettle();

    expect(find.text('JCHESS'), findsOneWidget);
    expect(find.text('Nova partida'), findsOneWidget);
    expect(find.text('Aprender'), findsOneWidget);
    expect(find.text('Teu estilo de jogo'), findsOneWidget);
    expect(find.text('O que já está entrando'), findsNothing);
  });

  testWidgets('mostra atalho para continuar a partida salva', (tester) async {
    final controller = AppController();
    await controller.saveActiveGame(
      const GameConfig(
        mode: GameMode.bot,
        humanIsWhite: true,
        botLevel: 4,
        botId: 'ravi',
      ),
      const [],
    );

    await tester.pumpWidget(JChessApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Continuar partida'), findsOneWidget);
    expect(find.textContaining('Ravi'), findsOneWidget);
  });
}
