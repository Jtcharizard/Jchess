import 'dart:io';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.child,
    this.darken = .28,
    super.key,
  });

  final Widget child;
  final double darken;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final decoration = _decoration(app);

    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black.withValues(alpha: darken)),
          child,
        ],
      ),
    );
  }

  BoxDecoration _decoration(AppController app) {
    if (app.wallpaper == 'tokai') {
      return const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wallpapers/tokai_teio.jpg'),
          fit: BoxFit.cover,
        ),
      );
    }

    if (app.wallpaper == 'custom' &&
        app.customWallpaperPath != null &&
        File(app.customWallpaperPath!).existsSync()) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(app.customWallpaperPath!)),
          fit: BoxFit.cover,
        ),
      );
    }

    final colors = switch (app.wallpaper) {
      'midnight' => const [Color(0xFF101820), Color(0xFF243447)],
      'forest' => const [Color(0xFF10251B), Color(0xFF35583C)],
      'violet' => const [Color(0xFF21132E), Color(0xFF563770)],
      _ => const [Color(0xFF160F0B), Color(0xFF7A3212), Color(0xFFFF8A2A)],
    };

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    );
  }
}
