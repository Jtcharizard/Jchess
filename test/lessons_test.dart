import 'package:chess/chess.dart' as chesslib;
import 'package:flutter_test/flutter_test.dart';
import 'package:jchess/chess/lessons.dart';

void main() {
  group('Lições interativas', () {
    test('catálogo possui cinco capítulos e pelo menos 24 aulas', () {
      expect(lessonCatalog.length, greaterThanOrEqualTo(24));
    });

    for (var index = 0; index < lessonCatalog.length; index++) {
      final lesson = lessonCatalog[index];
      test('lição ${index + 1} tem posição e solução válidas', () {
        final game = chesslib.Chess.fromFEN(lesson.fen);
        final legalMoves = game
            .moves({'verbose': true})
            .whereType<Map>()
            .map((move) => '${move['from']}${move['to']}')
            .toSet();

        expect(
          legalMoves.intersection(lesson.acceptedMoves),
          isNotEmpty,
          reason: 'A solução de "${lesson.title}" precisa ser um lance legal.',
        );
      });
    }
  });
}
