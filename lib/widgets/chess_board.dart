import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PieceSet {
  const PieceSet({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

const pieceSets = <PieceSet>[
  PieceSet(
    id: 'chessnut',
    name: 'Chessnut',
    description: 'Clássico limpo',
  ),
  PieceSet(
    id: 'fantasy',
    name: 'Fantasia',
    description: 'Detalhado e elegante',
  ),
  PieceSet(
    id: 'spatial',
    name: 'Espacial',
    description: 'Moderno e afiado',
  ),
  PieceSet(
    id: 'celtic',
    name: 'Celta',
    description: 'Ornamentos medievais',
  ),
  PieceSet(
    id: 'rhosgfx',
    name: 'Retrô',
    description: 'Pixel art completa',
  ),
];

PieceSet pieceSetById(String id) => pieceSets.firstWhere(
      (set) => set.id == id,
      orElse: () => pieceSets.first,
    );

String pieceAssetPath(
  String setId, {
  required bool white,
  required String type,
}) {
  final safeSet = pieceSetById(setId).id;
  return 'assets/pieces/$safeSet/${white ? 'w' : 'b'}${type.toUpperCase()}.svg';
}

class ChessPieceImage extends StatelessWidget {
  const ChessPieceImage({
    required this.pieceSetId,
    required this.white,
    required this.type,
    this.size,
    super.key,
  });

  final String pieceSetId;
  final bool white;
  final String type;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      pieceAssetPath(pieceSetId, white: white, type: type),
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class BoardPalette {
  const BoardPalette({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
  });

  final String id;
  final String name;
  final Color light;
  final Color dark;
}

const boardPalettes = <BoardPalette>[
  BoardPalette(
    id: 'ember',
    name: 'Brasas',
    light: Color(0xFFFFD3A3),
    dark: Color(0xFFC85B22),
  ),
  BoardPalette(
    id: 'classic',
    name: 'Clássico',
    light: Color(0xFFF0D9B5),
    dark: Color(0xFFB58863),
  ),
  BoardPalette(
    id: 'ocean',
    name: 'Oceano',
    light: Color(0xFFC7E7F3),
    dark: Color(0xFF397F98),
  ),
  BoardPalette(
    id: 'violet',
    name: 'Violeta',
    light: Color(0xFFE5D5F4),
    dark: Color(0xFF76518F),
  ),
  BoardPalette(
    id: 'forest',
    name: 'Floresta',
    light: Color(0xFFD9E8C4),
    dark: Color(0xFF5E7D45),
  ),
  BoardPalette(
    id: 'graphite',
    name: 'Grafite',
    light: Color(0xFFBFC4CC),
    dark: Color(0xFF48515E),
  ),
  BoardPalette(
    id: 'ice',
    name: 'Gelo',
    light: Color(0xFFE4F4F8),
    dark: Color(0xFF8AB4C2),
  ),
  BoardPalette(
    id: 'sand',
    name: 'Areia',
    light: Color(0xFFF2DEB5),
    dark: Color(0xFFC4935C),
  ),
  BoardPalette(
    id: 'rosewood',
    name: 'Jacarandá',
    light: Color(0xFFE8BE94),
    dark: Color(0xFF8D4634),
  ),
  BoardPalette(
    id: 'emerald',
    name: 'Esmeralda',
    light: Color(0xFFE5EBD5),
    dark: Color(0xFF2F765C),
  ),
  BoardPalette(
    id: 'midnight',
    name: 'Meia-noite',
    light: Color(0xFF97A7BD),
    dark: Color(0xFF29364B),
  ),
  BoardPalette(
    id: 'candy',
    name: 'Doce',
    light: Color(0xFFF7D9E5),
    dark: Color(0xFFB76A8D),
  ),
];

BoardPalette boardPaletteById(String id) => boardPalettes.firstWhere(
      (palette) => palette.id == id,
      orElse: () => boardPalettes.first,
    );

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    required this.game,
    required this.onSquareTap,
    required this.paletteId,
    required this.pieceSetId,
    this.selectedSquare,
    this.legalTargets = const <String>{},
    this.lastFrom,
    this.lastTo,
    this.hintFrom,
    this.hintTo,
    this.flipped = false,
    this.showCoordinates = true,
    super.key,
  });

  final chesslib.Chess game;
  final ValueChanged<String>? onSquareTap;
  final String paletteId;
  final String pieceSetId;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final String? lastFrom;
  final String? lastTo;
  final String? hintFrom;
  final String? hintTo;
  final bool flipped;
  final bool showCoordinates;

  @override
  Widget build(BuildContext context) {
    final palette = boardPaletteById(paletteId);
    final files = flipped ? 'hgfedcba' : 'abcdefgh';
    final ranks = flipped
        ? const <int>[1, 2, 3, 4, 5, 6, 7, 8]
        : const <int>[8, 7, 6, 5, 4, 3, 2, 1];

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth / 8;
              return Column(
                children: [
                  for (var row = 0; row < 8; row++)
                    Row(
                      children: [
                        for (var column = 0; column < 8; column++)
                          _Square(
                            square: '${files[column]}${ranks[row]}',
                            piece: game.get('${files[column]}${ranks[row]}'),
                            pieceSetId: pieceSetId,
                            size: side,
                            baseColor: (row + column).isEven
                                ? palette.light
                                : palette.dark,
                            selected:
                                selectedSquare == '${files[column]}${ranks[row]}',
                            legalTarget: legalTargets
                                .contains('${files[column]}${ranks[row]}'),
                            lastMove: lastFrom ==
                                    '${files[column]}${ranks[row]}' ||
                                lastTo == '${files[column]}${ranks[row]}',
                            hint: hintFrom == '${files[column]}${ranks[row]}' ||
                                hintTo == '${files[column]}${ranks[row]}',
                            showFile: showCoordinates && row == 7,
                            showRank: showCoordinates && column == 0,
                            onTap: onSquareTap == null
                                ? null
                                : () => onSquareTap!(
                                      '${files[column]}${ranks[row]}',
                                    ),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({
    required this.square,
    required this.piece,
    required this.pieceSetId,
    required this.size,
    required this.baseColor,
    required this.selected,
    required this.legalTarget,
    required this.lastMove,
    required this.hint,
    required this.showFile,
    required this.showRank,
    required this.onTap,
  });

  final String square;
  final chesslib.Piece? piece;
  final String pieceSetId;
  final double size;
  final Color baseColor;
  final bool selected;
  final bool legalTarget;
  final bool lastMove;
  final bool hint;
  final bool showFile;
  final bool showRank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color color = baseColor;
    if (lastMove) color = Color.alphaBlend(const Color(0x66FFF176), color);
    if (hint) color = Color.alphaBlend(const Color(0x9957E389), color);
    if (selected) color = Color.alphaBlend(const Color(0xAAFFB74D), color);

    final occupiedTarget = legalTarget && piece != null;
    return Semantics(
      button: onTap != null,
      label: _semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: ColoredBox(
            color: color,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (occupiedTarget)
                  Container(
                    margin: EdgeInsets.all(size * .07),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withValues(alpha: .35),
                        width: size * .065,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (legalTarget && piece == null)
                  Center(
                    child: Container(
                      width: size * .24,
                      height: size * .24,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .28),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (piece != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(size * .035),
                      child: ChessPieceImage(
                        pieceSetId: pieceSetId,
                        white: piece!.color == chesslib.Color.WHITE,
                        type: piece!.type.name,
                        size: size * .93,
                      ),
                    ),
                  ),
                if (showRank)
                  Positioned(
                    top: 2,
                    left: 3,
                    child: Text(
                      square[1],
                      style: TextStyle(
                        color: _coordinateColor,
                        fontSize: size * .17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                if (showFile)
                  Positioned(
                    right: 3,
                    bottom: 1,
                    child: Text(
                      square[0],
                      style: TextStyle(
                        color: _coordinateColor,
                        fontSize: size * .17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _coordinateColor =>
      baseColor.computeLuminance() > .55 ? Colors.black54 : Colors.white70;

  String get _semanticsLabel {
    if (piece == null) return 'Casa $square vazia';
    final color =
        piece!.color == chesslib.Color.WHITE ? 'branca' : 'preta';
    return '${_pieceName(piece!)} $color em $square';
  }

  static String _pieceName(chesslib.Piece piece) => switch (piece.type.name) {
        'k' => 'Rei',
        'q' => 'Dama',
        'r' => 'Torre',
        'b' => 'Bispo',
        'n' => 'Cavalo',
        _ => 'Peão',
      };
}
