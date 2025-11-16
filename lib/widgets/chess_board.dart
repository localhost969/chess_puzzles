import 'dart:math' as math;

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

class ChessBoardWidget extends StatelessWidget {
  final String fen;
  final Side orientation;
  final GameData gameData;
  final NormalMove? lastMove;
  final ChessboardSettings? settings;

  const ChessBoardWidget({
    super.key,
    required this.fen,
    required this.orientation,
    required this.gameData,
    this.lastMove,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double shortestSide = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        ).toDouble();
        final double boardSize = shortestSide > 0 ? shortestSide : 320.0;
        return Chessboard(
          size: boardSize,
          orientation: orientation,
          fen: fen,
          lastMove: lastMove,
          settings: settings ?? const ChessboardSettings(),
          game: gameData,
        );
      },
    );
  }
}
