import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chess/game_models.dart';

enum GameResult { win, draw, loss, local }

class AppController extends ChangeNotifier {
  static const _boardThemeKey = 'boardTheme';
  static const _pieceSetKey = 'pieceSet';
  static const _wallpaperKey = 'wallpaper';
  static const _customWallpaperKey = 'customWallpaper';
  static const _botLevelKey = 'botLevel';
  static const _botIdKey = 'botId';
  static const _completedLessonsKey = 'completedLessons';
  static const _gamesKey = 'games';
  static const _winsKey = 'wins';
  static const _drawsKey = 'draws';
  static const _lossesKey = 'losses';
  static const _activeGameKey = 'activeGame';

  SharedPreferences? _preferences;

  String boardTheme = 'ember';
  String pieceSet = 'chessnut';
  String wallpaper = 'sunset';
  String? customWallpaperPath;
  int botLevel = 5;
  String botId = 'ravi';
  Set<int> completedLessons = <int>{};
  int games = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  SavedGame? activeGame;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final preferences = _preferences!;
    boardTheme = preferences.getString(_boardThemeKey) ?? 'ember';
    pieceSet = preferences.getString(_pieceSetKey) ?? 'chessnut';
    wallpaper = preferences.getString(_wallpaperKey) ?? 'sunset';
    customWallpaperPath = preferences.getString(_customWallpaperKey);
    botLevel = preferences.getInt(_botLevelKey) ?? 5;
    botId = preferences.getString(_botIdKey) ?? 'ravi';
    completedLessons = preferences
            .getStringList(_completedLessonsKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toSet() ??
        <int>{};
    games = preferences.getInt(_gamesKey) ?? 0;
    wins = preferences.getInt(_winsKey) ?? 0;
    draws = preferences.getInt(_drawsKey) ?? 0;
    losses = preferences.getInt(_lossesKey) ?? 0;
    final savedGameJson = preferences.getString(_activeGameKey);
    if (savedGameJson != null) {
      try {
        activeGame = SavedGame.fromJson(
          Map<String, dynamic>.from(jsonDecode(savedGameJson) as Map),
        );
      } catch (_) {
        activeGame = null;
        await preferences.remove(_activeGameKey);
      }
    }
  }

  Future<void> setBoardTheme(String value) async {
    boardTheme = value;
    notifyListeners();
    await _preferences?.setString(_boardThemeKey, value);
  }

  Future<void> setPieceSet(String value) async {
    pieceSet = value;
    notifyListeners();
    await _preferences?.setString(_pieceSetKey, value);
  }

  Future<void> setWallpaper(String value, {String? customPath}) async {
    wallpaper = value;
    if (customPath != null) {
      customWallpaperPath = customPath;
      await _preferences?.setString(_customWallpaperKey, customPath);
    }
    notifyListeners();
    await _preferences?.setString(_wallpaperKey, value);
  }

  Future<void> setBotLevel(int value) async {
    botLevel = value.clamp(0, 20).toInt();
    notifyListeners();
    await _preferences?.setInt(_botLevelKey, botLevel);
  }

  Future<void> setBot(String id, int level) async {
    botId = id;
    botLevel = level.clamp(0, 20).toInt();
    notifyListeners();
    await Future.wait([
      _preferences?.setString(_botIdKey, botId) ?? Future.value(true),
      _preferences?.setInt(_botLevelKey, botLevel) ?? Future.value(true),
    ]);
  }

  Future<void> completeLesson(int index) async {
    if (!completedLessons.add(index)) return;
    notifyListeners();
    await _preferences?.setStringList(
      _completedLessonsKey,
      completedLessons.map((item) => '$item').toList()..sort(),
    );
  }

  Future<void> saveActiveGame(
    GameConfig config,
    List<PlayedMove> moves,
  ) async {
    activeGame = SavedGame(
      config: config,
      moves: List<PlayedMove>.unmodifiable(moves),
      savedAt: DateTime.now(),
    );
    notifyListeners();
    await _preferences?.setString(
      _activeGameKey,
      jsonEncode(activeGame!.toJson()),
    );
  }

  Future<void> clearActiveGame() async {
    if (activeGame == null) return;
    activeGame = null;
    notifyListeners();
    await _preferences?.remove(_activeGameKey);
  }

  Future<void> recordGame(GameResult result) async {
    games++;
    switch (result) {
      case GameResult.win:
        wins++;
        break;
      case GameResult.draw:
        draws++;
        break;
      case GameResult.loss:
        losses++;
        break;
      case GameResult.local:
        break;
    }
    notifyListeners();
    await Future.wait([
      _preferences?.setInt(_gamesKey, games) ?? Future.value(true),
      _preferences?.setInt(_winsKey, wins) ?? Future.value(true),
      _preferences?.setInt(_drawsKey, draws) ?? Future.value(true),
      _preferences?.setInt(_lossesKey, losses) ?? Future.value(true),
    ]);
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore.');
    return scope!.notifier!;
  }
}

extension AppScopeContext on BuildContext {
  AppController get app => AppScope.of(this);
}
