import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../chess/bot_catalog.dart';

class BotPortrait extends StatelessWidget {
  const BotPortrait({
    required this.bot,
    required this.size,
    this.borderRadius,
    super.key,
  });

  final BotProfile bot;
  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Retrato de ${bot.name}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? size / 2),
        child: SizedBox.square(
          dimension: size,
          child: Image.asset(
            bot.portraitAsset,
            fit: BoxFit.cover,
            cacheWidth: 384,
            cacheHeight: 384,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: emberOrange.withValues(alpha: .16),
              child: Center(
                child: Text(
                  bot.emoji,
                  style: TextStyle(fontSize: size * .52),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
