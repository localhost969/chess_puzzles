import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Board Test',
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late chess_lib.Chess _chess;

  @override
  void initState() {
    super.initState();
    // Test FEN from CSV
    final testFen =
        'r6k/pp2r2p/4Rp1Q/3p4/8/1N1P2R1/PqP2bPP/7K b - - 0 24';
    _chess = chess_lib.Chess.fromFEN(testFen);
    print('Initialized chess with FEN: $testFen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Board Test')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'FEN: ${_chess.fen}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
              // Chess board
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final col = index % 8;
                    final file = String.fromCharCode(97 + col);
                    final rank = (8 - row).toString();
                    final square = '$file$rank';

                    final piece = _chess.get(square);
                    final isLight = (row + col) % 2 == 0;
                    final backgroundColor =
                        isLight ? Color(0xfff0d9b5) : Color(0xffb58863);

                    return Container(
                      color: backgroundColor,
                      child: piece != null
                          ? Center(
                              child: Text(
                                _getPieceSymbol(piece),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 40),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Click on squares to select pieces'),
            ],
          ),
        ),
      ),
    );
  }

  String _getPieceSymbol(chess_lib.Piece piece) {
    const symbols = {
      ('WHITE', 'PAWN'): '♙',
      ('WHITE', 'KNIGHT'): '♘',
      ('WHITE', 'BISHOP'): '♗',
      ('WHITE', 'ROOK'): '♖',
      ('WHITE', 'QUEEN'): '♕',
      ('WHITE', 'KING'): '♔',
      ('BLACK', 'PAWN'): '♟',
      ('BLACK', 'KNIGHT'): '♞',
      ('BLACK', 'BISHOP'): '♝',
      ('BLACK', 'ROOK'): '♜',
      ('BLACK', 'QUEEN'): '♛',
      ('BLACK', 'KING'): '♚',
    };

    final key = (piece.color.name, piece.type.name);
    return symbols[key] ?? '?';
  }
}
