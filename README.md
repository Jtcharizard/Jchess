<p align="center">
  <img src="assets/branding/app_icon.png" width="120" alt="Ícone do JChess">
</p>

<h1 align="center">JChess</h1>

<p align="center">
  <strong>Xadrez offline, educativo e com personalidade.</strong><br>
  Joga contra o Stockfish, aprende no próprio tabuleiro e revisa cada decisão.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Android-54C5F8?logo=flutter&logoColor=white">
  <img alt="Offline" src="https://img.shields.io/badge/funciona-offline-ff8a2a">
  <img alt="Licença MIT" src="https://img.shields.io/badge/c%C3%B3digo-MIT-8c4a25">
  <a href="../../actions/workflows/android.yml"><img alt="Build Android" src="../../actions/workflows/android.yml/badge.svg"></a>
</p>

## O que já existe na v0.4.1

- Dez bots com nome, retrato próprio, personalidade visual e forças de 0 a 20, todos movidos
  pelo **Stockfish 18** offline.
- A partida em andamento é salva automaticamente após cada lance e pode ser
  continuada da mesma posição mesmo depois de fechar o aplicativo.
- Partida local para duas pessoas no mesmo celular.
- Regras legais de xadrez: xeque, mate, empate, roque, promoção e *en passant*.
- Seleção de casas, movimentos possíveis, último lance, girar tabuleiro e desfazer.
- Dica calculada pelo motor sem depender de internet.
- Revisão pós-partida com marcos clicáveis de abertura, viradas, momento
  crítico, entrada no final e desfecho, além da análise lance por lance.
- Vinte e quatro lições interativas em português, organizadas em cinco capítulos.
- Vinte paletas de tabuleiro, quinze conjuntos completos de peças e cinco fundos,
  incluindo a arte da Tokai Teio.
- Upload de wallpaper direto da galeria do celular.
- Estatísticas e progresso das lições salvos no aparelho.
- Perfil de gameplay baseado nas revisões: precisão geral, fase mais forte,
  erro recorrente, segurança da rainha e frequência de roque.
- Exportação da partida em PGN para a área de transferência.

## APK pelo celular

O próprio GitHub compila o aplicativo:

1. Abra a aba **Actions** deste repositório.
2. Entre em **Android • Gerar APK**.
3. Toque em **Run workflow**.
4. Quando terminar, baixe o artefato **JChess-APK-v0.4.1-arm64**.
5. Extraia o arquivo e instale `JChess-v0.4.1-arm64.apk`.

O APK é ARM64 para não carregar três cópias gigantes do Stockfish. Essa é a
arquitetura usada pela imensa maioria dos celulares Android atuais.

Cada envio para a branch `main` também inicia uma compilação automaticamente.

## Rodar localmente

```bash
flutter create --platforms=android --org com.jtcharizard --project-name jchess .
flutter pub get
dart run flutter_launcher_icons
flutter run
```

O Android precisa usar `minSdk 24` por causa do seletor moderno de imagens.

## Estrutura

```text
lib/
├── app/       tema, preferências e estatísticas
├── chess/     modelos, lições e comunicação UCI com o Stockfish
├── screens/   início, partida, análise, aprendizado e personalização
└── widgets/   tabuleiro e fundos reutilizáveis
```

## Próximos passos

- Salvar histórico de partidas e importar PGN.
- Relógios Bullet, Blitz e Rápida.
- Exercícios táticos gerados a partir dos erros do jogador.
- Mais wallpapers originais.
- Conquistas, sequência diária e desafios.
- Multiplayer online em uma etapa separada, com servidor e contas.

## Créditos e licença

O JChess usa [`chess.dart`](https://pub.dev/packages/chess) para validar as regras
e [`stockfish`](https://pub.dev/packages/stockfish) como motor local. O código do
JChess mantém a licença MIT do repositório; o Stockfish é GPL-3.0 e as
distribuições do APK precisam respeitar os termos dessa licença. Veja os
[avisos de terceiros](THIRD_PARTY_NOTICES.md). **JChess não é afiliado ao
Chess.com** e não usa o nome, a marca nem os elementos visuais oficiais da
plataforma.
