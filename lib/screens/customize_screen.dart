import 'dart:io';

import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../widgets/chess_board.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Monta o teu tabuleiro, peça por peça.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.auto_awesome_rounded, color: emberOrange),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ChessBoard(
                      game: chesslib.Chess(),
                      paletteId: app.boardTheme,
                      pieceSetId: app.pieceSet,
                      showCoordinates: false,
                      onSquareTap: null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xC91C1714),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: 'Tabuleiro'),
                  Tab(text: 'Peças'),
                  Tab(text: 'Fundo'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Expanded(
              child: TabBarView(
                children: [
                  _BoardTab(),
                  _PiecesTab(),
                  _WallpaperTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> pickWallpaper(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1800,
      );
      if (picked == null || !context.mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final extension = picked.path.split('.').last.toLowerCase();
      final safeExtension = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)
          ? extension
          : 'jpg';
      final destination =
          '${directory.path}/jchess_wallpaper_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
      await File(picked.path).copy(destination);
      if (!context.mounted) return;
      await context.app.setWallpaper('custom', customPath: destination);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não consegui importar essa imagem.')),
      );
    }
  }
}

class _BoardTab extends StatelessWidget {
  const _BoardTab();

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 115),
      children: [
        const _SectionIntro(
          icon: Icons.grid_view_rounded,
          title: 'Cores do tabuleiro',
          text: 'A cor muda sem mexer no conjunto de peças.',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: boardPalettes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.56,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final palette = boardPalettes[index];
            return _BoardPaletteTile(
              palette: palette,
              selected: app.boardTheme == palette.id,
              onTap: () => app.setBoardTheme(palette.id),
            );
          },
        ),
      ],
    );
  }
}

class _PiecesTab extends StatelessWidget {
  const _PiecesTab();

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 115),
      children: [
        const _SectionIntro(
          icon: Icons.interests_rounded,
          title: 'Conjuntos completos',
          text: 'Cada opção troca rei, dama, torres, bispos, cavalos e peões juntos.',
        ),
        const SizedBox(height: 14),
        for (final set in pieceSets) ...[
          _PieceSetTile(
            set: set,
            selected: app.pieceSet == set.id,
            onTap: () => app.setPieceSet(set.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WallpaperTab extends StatelessWidget {
  const _WallpaperTab();

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 115),
      children: [
        const _SectionIntro(
          icon: Icons.wallpaper_rounded,
          title: 'Fundo do aplicativo',
          text: 'Escolhe um clima ou coloca uma imagem da tua galeria.',
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: .92,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _WallpaperTile(
              label: 'Pôr do sol',
              selected: app.wallpaper == 'sunset',
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF160F0B),
                    Color(0xFF9B4017),
                    Color(0xFFFF8A2A),
                  ],
                ),
              ),
              onTap: () => app.setWallpaper('sunset'),
            ),
            _WallpaperTile(
              label: 'Meia-noite',
              selected: app.wallpaper == 'midnight',
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF101820), Color(0xFF385066)],
                ),
              ),
              onTap: () => app.setWallpaper('midnight'),
            ),
            _WallpaperTile(
              label: 'Floresta',
              selected: app.wallpaper == 'forest',
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10251B), Color(0xFF4E774C)],
                ),
              ),
              onTap: () => app.setWallpaper('forest'),
            ),
            _WallpaperTile(
              label: 'Violeta',
              selected: app.wallpaper == 'violet',
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF21132E), Color(0xFF76518F)],
                ),
              ),
              onTap: () => app.setWallpaper('violet'),
            ),
            _WallpaperTile(
              label: 'Tokai Teio',
              selected: app.wallpaper == 'tokai',
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/wallpapers/tokai_teio.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () => app.setWallpaper('tokai'),
            ),
            _UploadWallpaperTile(
              selected: app.wallpaper == 'custom',
              imagePath: app.customWallpaperPath,
              onTap: () => CustomizeScreen.pickWallpaper(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: emberOrange.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: emberOrange),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                text,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieceSetTile extends StatelessWidget {
  const _PieceSetTile({
    required this.set,
    required this.selected,
    required this.onTap,
  });

  final PieceSet set;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const types = ['k', 'q', 'r', 'b', 'n', 'p'];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? emberOrange : Colors.white10,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          set.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 7),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: emberOrange,
                            size: 18,
                          ),
                      ],
                    ),
                    Text(
                      set.description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        for (final type in types)
                          Expanded(
                            child: SvgPicture.asset(
                              pieceAssetPath(
                                set.id,
                                white: true,
                                type: type,
                              ),
                              height: 29,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0D9B5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(
                  pieceAssetPath(set.id, white: false, type: 'n'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardPaletteTile extends StatelessWidget {
  const _BoardPaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final BoardPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: BorderSide(
          color: selected ? emberOrange : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (_, index) => ColoredBox(
                      color: ((index ~/ 4) + index).isEven
                          ? palette.light
                          : palette.dark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  palette.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: emberOrange, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  const _WallpaperTile({
    required this.label,
    required this.selected,
    required this.decoration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final BoxDecoration decoration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        decoration: decoration.copyWith(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? emberOrange : Colors.white12,
            width: selected ? 3 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (selected)
              const Positioned(
                top: 9,
                right: 9,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: emberOrange,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadWallpaperTile extends StatelessWidget {
  const _UploadWallpaperTile({
    required this.selected,
    required this.imagePath,
    required this.onTap,
  });

  final bool selected;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A221D),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? emberOrange : Colors.white12,
            width: selected ? 3 : 1,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withValues(alpha: hasImage ? .45 : .10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasImage
                    ? Icons.add_photo_alternate_rounded
                    : Icons.upload_rounded,
                color: emberOrange,
                size: 36,
              ),
              const SizedBox(height: 9),
              Text(
                hasImage ? 'Trocar tua foto' : 'Enviar tua foto',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
