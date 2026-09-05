class BotProfile {
  const BotProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.portraitAsset,
    required this.level,
    required this.thinkTimeMs,
    required this.tagline,
  });

  final String id;
  final String name;
  final String emoji;
  final String portraitAsset;
  final int level;
  final int thinkTimeMs;
  final String tagline;
}

const botCatalog = <BotProfile>[
  BotProfile(
    id: 'nina',
    name: 'Nina',
    emoji: '🙂',
    portraitAsset: 'assets/bots/nina.png',
    level: 0,
    thinkTimeMs: 240,
    tagline: 'Primeiros passos no tabuleiro',
  ),
  BotProfile(
    id: 'leo',
    name: 'Léo',
    emoji: '😄',
    portraitAsset: 'assets/bots/leo.png',
    level: 2,
    thinkTimeMs: 280,
    tagline: 'Joga rápido e deixa brechas',
  ),
  BotProfile(
    id: 'ravi',
    name: 'Ravi',
    emoji: '🧐',
    portraitAsset: 'assets/bots/ravi.png',
    level: 4,
    thinkTimeMs: 330,
    tagline: 'Já conhece os truques básicos',
  ),
  BotProfile(
    id: 'maia',
    name: 'Maia',
    emoji: '🛡️',
    portraitAsset: 'assets/bots/maia.png',
    level: 6,
    thinkTimeMs: 380,
    tagline: 'Paciente e difícil de pressionar',
  ),
  BotProfile(
    id: 'theo',
    name: 'Theo',
    emoji: '⚔️',
    portraitAsset: 'assets/bots/theo.png',
    level: 8,
    thinkTimeMs: 440,
    tagline: 'Sempre procura atacar o rei',
  ),
  BotProfile(
    id: 'iris',
    name: 'Íris',
    emoji: '🧠',
    portraitAsset: 'assets/bots/iris.png',
    level: 10,
    thinkTimeMs: 520,
    tagline: 'Calcula antes de encostar na peça',
  ),
  BotProfile(
    id: 'dante',
    name: 'Dante',
    emoji: '🎯',
    portraitAsset: 'assets/bots/dante.png',
    level: 12,
    thinkTimeMs: 610,
    tagline: 'Constrói vantagem lance por lance',
  ),
  BotProfile(
    id: 'aurora',
    name: 'Aurora',
    emoji: '♛',
    portraitAsset: 'assets/bots/aurora.png',
    level: 14,
    thinkTimeMs: 720,
    tagline: 'Uma mestra de posições complicadas',
  ),
  BotProfile(
    id: 'viktor',
    name: 'Viktor',
    emoji: '👑',
    portraitAsset: 'assets/bots/viktor.png',
    level: 17,
    thinkTimeMs: 880,
    tagline: 'Força de jogador de torneio',
  ),
  BotProfile(
    id: 'nox',
    name: 'Nox',
    emoji: '♚',
    portraitAsset: 'assets/bots/nox.png',
    level: 20,
    thinkTimeMs: 1200,
    tagline: 'Stockfish no máximo. Sem conversa.',
  ),
];

BotProfile botById(String id) => botCatalog.firstWhere(
      (bot) => bot.id == id,
      orElse: () => botCatalog[2],
    );
