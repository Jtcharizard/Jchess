class ChessLesson {
  const ChessLesson({
    required this.title,
    required this.category,
    required this.description,
    required this.instruction,
    required this.fen,
    required this.acceptedMoves,
    required this.hint,
    required this.success,
  });

  final String title;
  final String category;
  final String description;
  final String instruction;
  final String fen;
  final Set<String> acceptedMoves;
  final String hint;
  final String success;
}

const lessonCatalog = <ChessLesson>[
  ChessLesson(
    title: 'O primeiro passo',
    category: 'PEÃO',
    description: 'Peões andam para frente e capturam na diagonal.',
    instruction: 'Leva o peão de e2 até e4 em um único lance.',
    fen: '7k/8/8/8/8/8/4P3/4K3 w - - 0 1',
    acceptedMoves: {'e2e4'},
    hint: 'No primeiro movimento, o peão pode avançar duas casas.',
    success: 'Boa! Depois disso ele passa a andar somente uma casa por vez.',
  ),
  ChessLesson(
    title: 'A torre é um trem',
    category: 'TORRE',
    description: 'Ela cruza linhas e colunas, mas nunca faz curva.',
    instruction: 'Move a torre de a1 até a8.',
    fen: '7k/8/8/8/8/8/8/R6K w - - 0 1',
    acceptedMoves: {'a1a8'},
    hint: 'Sobe reto pela coluna a. Não tem nenhuma peça bloqueando.',
    success: 'Perfeito. Torres ficam especialmente fortes em colunas abertas.',
  ),
  ChessLesson(
    title: 'Cortando na diagonal',
    category: 'BISPO',
    description: 'O bispo atravessa o tabuleiro pelas diagonais.',
    instruction: 'Leva o bispo de c1 até h6.',
    fen: '7k/8/8/8/8/8/8/2B4K w - - 0 1',
    acceptedMoves: {'c1h6'},
    hint: 'Segue pelas casas d2, e3, f4, g5 e h6.',
    success: 'Isso aí. Um bispo nunca muda a cor das casas em que joga.',
  ),
  ChessLesson(
    title: 'O cavalo diferentão',
    category: 'CAVALO',
    description: 'Ele anda em L e é a única peça que pula outras peças.',
    instruction: 'Salta com o cavalo de g1 para f3.',
    fen: '7k/8/8/8/8/8/8/6NK w - - 0 1',
    acceptedMoves: {'g1f3'},
    hint: 'Duas casas para cima e uma para o lado: esse é o L.',
    success: 'Acertou. Cavalos adoram o centro e detestam os cantos.',
  ),
  ChessLesson(
    title: 'A peça mais poderosa',
    category: 'DAMA',
    description: 'A dama combina os movimentos da torre e do bispo.',
    instruction: 'Move a dama de d1 até h5.',
    fen: '7k/8/8/8/8/8/8/3Q3K w - - 0 1',
    acceptedMoves: {'d1h5'},
    hint: 'Dessa vez ela vai pela diagonal: e2, f3, g4, h5.',
    success: 'Mandou bem. Só não coloca a dama em perigo cedo demais.',
  ),
  ChessLesson(
    title: 'Captura e pressão',
    category: 'CAPTURA',
    description: 'Uma peça pode ocupar a casa de uma inimiga e removê-la.',
    instruction: 'A torre preta está desprotegida. Captura ela.',
    fen: 'r6k/8/8/8/8/8/8/R6K w - - 0 1',
    acceptedMoves: {'a1a8'},
    hint: 'As duas torres estão na mesma coluna e não há nada entre elas.',
    success: 'Captura limpa — e ainda veio com xeque no rei preto.',
  ),
  ChessLesson(
    title: 'Atacando o rei',
    category: 'XEQUE',
    description: 'Xeque é um ataque direto ao rei adversário.',
    instruction: 'Move a torre para a oitava fileira e dá xeque.',
    fen: '7k/8/8/8/8/8/8/4R2K w - - 0 1',
    acceptedMoves: {'e1e8'},
    hint: 'Na casa e8, a torre vai enxergar o rei pela horizontal.',
    success: 'Xeque! Agora o adversário seria obrigado a resolver a ameaça.',
  ),
  ChessLesson(
    title: 'Mate em um',
    category: 'TÁTICA',
    description: 'O rei preto está preso. Falta encontrar o golpe final.',
    instruction: 'Encontra o xeque-mate em apenas um lance.',
    fen: '7k/5Q2/6K1/8/8/8/8/8 w - - 0 1',
    acceptedMoves: {'f7g7'},
    hint: 'A dama pode chegar em g7 protegida pelo teu rei.',
    success: 'Xeque-mate! O rei não consegue fugir nem capturar a dama.',
  ),
  ChessLesson(
    title: 'Protege o rei',
    category: 'ROQUE',
    description: 'O roque move rei e torre juntos para buscar segurança.',
    instruction: 'Faz o roque pequeno das brancas.',
    fen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
    acceptedMoves: {'e1g1'},
    hint: 'Seleciona o rei em e1 e leva ele duas casas até g1.',
    success: 'Rei protegido e torre ativada — dois problemas resolvidos de uma vez.',
  ),
  ChessLesson(
    title: 'En passant sem mistério',
    category: 'REGRA ESPECIAL',
    description: 'Um peão que avançou duas casas pode ser capturado de passagem.',
    instruction: 'Faz a captura en passant com o peão branco.',
    fen: '7k/8/8/3pP3/8/8/8/7K w - d6 0 2',
    acceptedMoves: {'e5d6'},
    hint: 'Move o peão de e5 para d6, como se o peão preto tivesse andado só uma.',
    success: 'É esquisito na primeira vez, mas agora tu já conhece o famoso en passant.',
  ),
];

