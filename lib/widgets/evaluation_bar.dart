import 'package:flutter/material.dart';
import '../models/puzzle.dart';

class EvaluationBar extends StatelessWidget {
  final Puzzle puzzle;

  const EvaluationBar({super.key, required this.puzzle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Themes: ${puzzle.themes.join(', ')}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
