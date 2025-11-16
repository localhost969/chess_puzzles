import 'package:flutter/material.dart';

class MoveHistory extends StatelessWidget {
  final List<String> moves;
  final int currentMoveIndex;

  const MoveHistory({
    super.key,
    required this.moves,
    required this.currentMoveIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentMoveIndex,
        itemBuilder: (context, index) {
          final move = moves[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                move,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          );
        },
      ),
    );
  }
}
