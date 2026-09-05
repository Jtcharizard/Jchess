import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/app/app_controller.dart';
import 'package:jchess/main.dart';

void main() {
  testWidgets('abre a tela inicial do JChess', (tester) async {
    await tester.pumpWidget(JChessApp(controller: AppController()));
    await tester.pumpAndSettle();

    expect(find.text('JCHESS'), findsOneWidget);
    expect(find.text('Nova partida'), findsOneWidget);
    expect(find.text('Aprender'), findsOneWidget);
  });
}

