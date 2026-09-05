import 'dart:io';

import 'package:flutter/material.dart';
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
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          const Text('Visual', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text(
            'Deixa o tabuleiro com a tua cara.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Fundo do aplicativo', icon: Icons.wallpaper_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 152,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _WallpaperTile(
                  label: 'Pôr do sol',
                  selected: app.wallpaper == 'sunset',
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF160F0B), Color(0xFF9B4017), Color(0xFFFF8A2A)],
                    ),
                  ),
                  onTap: () => app.setWallpaper('sunset'),
                ),
                _WallpaperTile(
                  label: 'Meia-noite',
                  selected: app.wallpaper == 'midnight',
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF101820), Color(0xFF385066)]),
                  ),
                  onTap: () => app.setWallpaper('midnight'),
                ),
                _WallpaperTile(
                  label: 'Floresta',
                  selected: app.wallpaper == 'forest',
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF10251B), Color(0xFF4E774C)]),
                  ),
                  onTap: () => app.setWallpaper('forest'),
                ),
                _WallpaperTile(
                  label: 'Violeta',
                  selected: app.wallpaper == 'violet',
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF21132E), Color(0xFF76518F)]),
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
                  onTap: () => _pickWallpaper(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Cores do tabuleiro', icon: Icons.grid_view_rounded),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boardPalettes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.65,
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
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Bot padrão', icon: Icons.smart_toy_rounded),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Nível sugerido', style: TextStyle(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(
                        '${app.botLevel}/20',
                        style: const TextStyle(color: emberOrange, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Slider(
                    value: app.botLevel.toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    onChanged: (value) => app.setBotLevel(value.round()),
                  ),
                  const Text(
                    'Tu ainda pode mudar o nível antes de cada partida.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWallpaper(BuildContext context) async {
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: emberOrange, size: 21),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: 104,
          decoration: decoration.copyWith(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: selected ? emberOrange : Colors.white12, width: selected ? 3 : 1),
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
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 9,
                right: 9,
                bottom: 9,
                child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              if (selected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle_rounded, color: emberOrange, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadWallpaperTile extends StatelessWidget {
  const _UploadWallpaperTile({required this.selected, required this.imagePath, required this.onTap});

  final bool selected;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: 104,
          decoration: BoxDecoration(
            color: const Color(0xFF2A221D),
            image: hasImage
                ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover)
                : null,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: selected ? emberOrange : Colors.white12, width: selected ? 3 : 1),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withValues(alpha: hasImage ? .38 : .08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(hasImage ? Icons.add_photo_alternate_rounded : Icons.upload_rounded, color: emberOrange, size: 30),
                const SizedBox(height: 8),
                Text(
                  hasImage ? 'Trocar foto' : 'Tua foto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPaletteTile extends StatelessWidget {
  const _BoardPaletteTile({required this.palette, required this.selected, required this.onTap});

  final BoardPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? emberOrange : Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: 16,
                    itemBuilder: (_, index) => ColoredBox(
                      color: ((index ~/ 4) + index).isEven ? palette.light : palette.dark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(palette.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              if (selected) const Icon(Icons.check_rounded, color: emberOrange, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
