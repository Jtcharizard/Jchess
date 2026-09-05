import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/app_theme.dart';
import '../chess/lessons.dart';
import 'lesson_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = context.app.completedLessons;
    final progress = completed.length / lessonCatalog.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          const Text(
            'Aprender',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Sem textão: mexe as peças e aprende fazendo.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: emberOrange.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.school_rounded, color: emberOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${completed.length} de ${lessonCatalog.length} concluídas',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const Text(
                              'Trilha para quem está começando',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(color: emberOrange, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(value: progress, minHeight: 9),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Trilha iniciante',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < lessonCatalog.length; index++) ...[
            _LessonTile(
              index: index,
              lesson: lessonCatalog[index],
              completed: completed.contains(index),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LessonScreen(index: index)),
              ),
            ),
            if (index != lessonCatalog.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.completed,
    required this.onTap,
  });

  final int index;
  final ChessLesson lesson;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF64D896).withValues(alpha: .18)
                      : emberOrange.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: completed
                    ? const Icon(Icons.check_rounded, color: Color(0xFF64D896))
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(color: emberOrange, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.category,
                      style: const TextStyle(color: emberOrange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .8),
                    ),
                    const SizedBox(height: 3),
                    Text(lesson.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      lesson.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

