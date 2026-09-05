import 'package:flutter/material.dart';

import 'app/app_controller.dart';
import 'app/app_theme.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.load();
  runApp(JChessApp(controller: controller));
}

class JChessApp extends StatelessWidget {
  const JChessApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          title: 'JChess',
          debugShowCheckedModeBanner: false,
          theme: buildJChessTheme(),
          home: const HomeShell(),
        ),
      ),
    );
  }
}

