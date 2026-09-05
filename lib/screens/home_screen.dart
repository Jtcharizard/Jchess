import 'dart:math';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../chess/bot_catalog.dart';
import '../chess/game_models.dart';
import '../widgets/bot_portrait.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
        children: [
          const _BrandHeader(),
          if (app.activeGame != null) ...[
            const SizedBox(height: 18),
            _ResumeGameCard(
              game: app.activeGame!,
              onContinue: () => _resumeGame(context, app.activeGame!),
              onDiscard: () => _discardGame(context),
            ),
          ],
          const SizedBox(height: 22),
          _PlayHero(
            onPlay: () => _openBotSetup(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.people_alt_rounded,
                  title: 'No mesmo celular',
                  subtitle: '2 jogadores',
                  onTap: () => _startLocalGame(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.auto_graph_rounded,
                  title: 'Revisão completa',
                  subtitle: 'Após cada partida',
                  onTap: () => _openBotSetup(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Teu progresso',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                '${app.games} partidas',
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatsCard(app: app),
          const SizedBox(height: 24),
          const Text(
            'O que já está entrando',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const _FeatureRow(
            icon: Icons.psychology_alt_rounded,
            title: 'Stockfish offline',
            text: 'Bot ajustável do nível 0 ao 20.',
          ),
          const SizedBox(height: 10),
          const _FeatureRow(
            icon: Icons.lightbulb_rounded,
            title: 'Dicas de verdade',
            text: 'Mostra um lance forte quando tu empacar.',
          ),
          const SizedBox(height: 10),
          const _FeatureRow(
            icon: Icons.analytics_rounded,
            title: 'Análise lance por lance',
            text: 'Melhor lance, erros, precisão e explicação simples.',
          ),
        ],
      ),
    );
  }

  Future<void> _openBotSetup(BuildContext context) async {
    final config = await showModalBottomSheet<GameConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF211B17),
      showDragHandle: true,
      builder: (_) => _GameSetupSheet(initialBotId: context.app.botId),
    );
    if (config == null || !context.mounted) return;
    await context.app.setBot(config.botId, config.botLevel);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(config: config)),
    );
  }

  Future<void> _startLocalGame(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          config: GameConfig(
            mode: GameMode.local,
            humanIsWhite: true,
            botLevel: 0,
            botId: 'local',
          ),
        ),
      ),
    );
  }

  Future<void> _resumeGame(BuildContext context, SavedGame game) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          config: game.config,
          initialMoves: game.moves,
        ),
      ),
    );
  }

  Future<void> _discardGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descartar partida?'),
        content: const Text(
          'A posição salva será apagada e não poderá ser continuada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.app.clearActiveGame();
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Color(0x66FF8A2A), blurRadius: 20),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/branding/app_icon.png',
            fit: BoxFit.cover,
            cacheWidth: 144,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JCHESS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Joga. Aprende. Volta mais forte.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Sobre o JChess',
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'JChess',
            applicationVersion: '0.4.0',
            applicationIcon: Image.asset(
              'assets/branding/app_icon.png',
              width: 54,
              height: 54,
            ),
            children: const [
              Text('Xadrez offline, educativo e personalizável.'),
            ],
          ),
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
    );
  }
}

class _PlayHero extends StatelessWidget {
  const _PlayHero({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF26170F),
            Color(0xFF7B3516),
            Color(0xFFFF8A2A),
          ],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 22, offset: Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: 16,
            top: 5,
            child: Text(
              '♞',
              style: TextStyle(
                color: Color(0x33FFFFFF),
                fontSize: 150,
                height: 1,
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: -22,
            child: Transform.rotate(
              angle: -.12,
              child: const _HeroMiniBoard(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00120D09), Color(0xF2120D09)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: emberOrange,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'JOGAR AGORA',
                        style: TextStyle(
                          color: Color(0xFF23150A),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Bota o bot\nno lugar dele.',
                      style: TextStyle(
                        fontSize: 30,
                        height: .98,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onPlay,
                        icon: const Icon(Icons.sports_esports_rounded),
                        label: const Text('Nova partida'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniBoard extends StatelessWidget {
  const _HeroMiniBoard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: 16,
        itemBuilder: (_, index) {
          final row = index ~/ 4;
          final column = index % 4;
          return ColoredBox(
            color: (row + column).isEven
                ? const Color(0x17FFFFFF)
                : const Color(0x18000000),
          );
        },
      ),
    );
  }
}

class _ResumeGameCard extends StatelessWidget {
  const _ResumeGameCard({
    required this.game,
    required this.onContinue,
    required this.onDiscard,
  });

  final SavedGame game;
  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final bot = game.config.mode == GameMode.bot
        ? botById(game.config.botId)
        : null;
    final opponent = game.config.mode == GameMode.bot
        ? botById(game.config.botId).name
        : 'partida local';
    final moveCount = game.moves.length;
    final detail = moveCount == 0
        ? 'Ainda sem lances'
        : '$moveCount ${moveCount == 1 ? 'lance' : 'lances'} · último: ${game.moves.last.san}';

    return Card(
      color: const Color(0xFF332219),
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: emberOrange.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: bot == null
                    ? const Icon(Icons.people_alt_rounded, color: emberOrange)
                    : BotPortrait(bot: bot, size: 48, borderRadius: 15),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continuar partida',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Contra $opponent · $detail',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Descartar partida salva',
                onPressed: onDiscard,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: emberOrange, size: 28),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.app});

  final AppController app;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            _Stat(value: '${app.wins}', label: 'Vitórias', color: Colors.greenAccent),
            _Stat(value: '${app.draws}', label: 'Empates', color: Colors.amberAccent),
            _Stat(value: '${app.losses}', label: 'Derrotas', color: Colors.redAccent),
            _Stat(
              value: '${app.completedLessons.length}',
              label: 'Lições',
              color: emberOrange,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: emberOrange.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: emberOrange),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameSetupSheet extends StatefulWidget {
  const _GameSetupSheet({required this.initialBotId});

  final String initialBotId;

  @override
  State<_GameSetupSheet> createState() => _GameSetupSheetState();
}

class _GameSetupSheetState extends State<_GameSetupSheet> {
  late String _selectedBotId;
  SideChoice _side = SideChoice.white;

  @override
  void initState() {
    super.initState();
    _selectedBotId = botById(widget.initialBotId).id;
  }

  @override
  Widget build(BuildContext context) {
    final selectedBot = botById(_selectedBotId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preparar partida',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolhe teu adversário e depois decide a cor.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Elenco de bots',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: emberOrange.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Nível ${selectedBot.level}/20',
                    style: const TextStyle(color: emberOrange, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 158,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: botCatalog.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  final bot = botCatalog[index];
                  return _BotCard(
                    bot: bot,
                    selected: bot.id == _selectedBotId,
                    onTap: () => setState(() => _selectedBotId = bot.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tua cor', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<SideChoice>(
                segments: const [
                  ButtonSegment(value: SideChoice.white, label: Text('Brancas'), icon: Text('♙')),
                  ButtonSegment(value: SideChoice.random, label: Text('Aleatória'), icon: Icon(Icons.casino_rounded)),
                  ButtonSegment(value: SideChoice.black, label: Text('Pretas'), icon: Text('♟')),
                ],
                selected: {_side},
                onSelectionChanged: (value) => setState(() => _side = value.first),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final white = switch (_side) {
                    SideChoice.white => true,
                    SideChoice.black => false,
                    SideChoice.random => Random().nextBool(),
                  };
                  Navigator.pop(
                    context,
                    GameConfig(
                      mode: GameMode.bot,
                      humanIsWhite: white,
                      botLevel: selectedBot.level,
                      botId: selectedBot.id,
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Começar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _BotCard extends StatelessWidget {
  const _BotCard({
    required this.bot,
    required this.selected,
    required this.onTap,
  });

  final BotProfile bot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 126,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? emberOrange.withValues(alpha: .16)
              : Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? emberOrange : Colors.white10,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BotPortrait(bot: bot, size: 54, borderRadius: 16),
            const Spacer(),
            Text(
              bot.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              bot.tagline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
