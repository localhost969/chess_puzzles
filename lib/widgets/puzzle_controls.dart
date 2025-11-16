import 'package:flutter/material.dart';

class PuzzleControls extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onGetHint;

  const PuzzleControls({
    super.key,
    required this.onReset,
    required this.onGetHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
            tooltip: 'Reset Puzzle',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: onGetHint,
            tooltip: 'Get a Hint',
          ),
        ],
      ),
    );
  }
}
