class BotProfile {
  const BotProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.level,
    required this.thinkTimeMs,
    required this.tagline,
  });

  final String id;
  final String name;
  final String emoji;
  final int level;
  final int thinkTimeMs;
  final String tagline;
}

const botCatalog = <BotProfile>[
  BotProfile(
    id: 'pingo',
    name: 'Pingo',
    emoji: '🐣',
    level: 0,
    thinkTimeMs: 240,
    tagline: 'Tá aprendendo contigo',
  ),
  BotProfile(
    id: 'faisca',
    name: 'Faísca',
    emoji: '⚡',
    level: 2,
    thinkTimeMs: 280,
    tagline: 'Rápido, mas deixa brechas',
  ),
  BotProfile(
    id: 'brasa',
    name: 'Brasa',
    emoji: '🔥',
    level: 4,
    thinkTimeMs: 330,
    tagline: 'Aquece a partida sem apelar',
  ),
  BotProfile(
    id: 'luna',
    name: 'Luna',
    emoji: '🌙',
    level: 6,
    thinkTimeMs: 380,
    tagline: 'Calma e traiçoeira',
  ),
  BotProfile(
    id: 'overtake',
    name: 'Overtake',
    emoji: '🏁',
    level: 8,
    thinkTimeMs: 440,
    tagline: 'Acelera quando vê vantagem',
  ),
  BotProfile(
    id: 'cartola',
    name: 'Cartola',
    emoji: '🎩',
    level: 10,
    thinkTimeMs: 520,
    tagline: 'Sempre guarda um truque',
  ),
  BotProfile(
    id: 'tiamati',
    name: 'Tiamati',
    emoji: '🐉',
    level: 12,
    thinkTimeMs: 610,
    tagline: 'Protege território e contra-ataca',
  ),
  BotProfile(
    id: 'aethern',
    name: 'Aethern',
    emoji: '✨',
    level: 14,
    thinkTimeMs: 720,
    tagline: 'Enxerga táticas bem longe',
  ),
  BotProfile(
    id: 'robisnelson',
    name: 'Robisnelson',
    emoji: '🔨',
    level: 17,
    thinkTimeMs: 880,
    tagline: 'Castiga qualquer vacilo',
  ),
  BotProfile(
    id: 'sem_piedade',
    name: 'Sem Piedade',
    emoji: '☠️',
    level: 20,
    thinkTimeMs: 1200,
    tagline: 'Stockfish no máximo. Boa sorte.',
  ),
];

BotProfile botById(String id) => botCatalog.firstWhere(
      (bot) => bot.id == id,
      orElse: () => botCatalog[2],
    );
