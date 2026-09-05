import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/chess/bot_catalog.dart';
import 'package:jchess/widgets/chess_board.dart';

void main() {
  test('elenco tem níveis válidos e identificadores únicos', () {
    expect(botCatalog.length, greaterThanOrEqualTo(10));
    expect(botCatalog.map((bot) => bot.id).toSet().length, botCatalog.length);
    expect(
      botCatalog.every((bot) => bot.level >= 0 && bot.level <= 20),
      isTrue,
    );
  });

  test('cada tema possui o conjunto completo de peças', () {
    const colors = ['w', 'b'];
    const types = ['K', 'Q', 'R', 'B', 'N', 'P'];

    for (final set in pieceSets) {
      for (final color in colors) {
        for (final type in types) {
          final file = File('assets/pieces/${set.id}/$color$type.svg');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Falta ${file.path} no conjunto ${set.name}.',
          );
        }
      }
    }
  });
}
