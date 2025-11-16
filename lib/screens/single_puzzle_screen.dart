import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../widgets/index.dart';

class SinglePuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;
  final int puzzleNumber;
  final ProgressService progressService;

  const SinglePuzzleScreen({
    super.key,
    required this.puzzle,
    required this.puzzleNumber,
    required this.progressService,
  });

  @override
  State<SinglePuzzleScreen> createState() => _SinglePuzzleScreenState();
}

class _SinglePuzzleScreenState extends State<SinglePuzzleScreen> {
  late Position _position;
  late Position _previousPosition;
  late Side _playerSide;
  ValidMoves _validMoves = IMap(const {});
  NormalMove? _lastMove;
  NormalMove? _promotionMove;
  bool _isSolved = false;
  int _currentMoveIndex = 0;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _initializePosition();
    _loadAttemptStatus();
  }

  void _initializePosition() {
    try {
      final setup = Setup.parseFen(widget.puzzle.fen);
      _position = Chess.fromSetup(setup);
      _playerSide = _position.turn.opposite; // User plays opposite side
      _validMoves = makeLegalMoves(_position);
      _currentMoveIndex = 0;
      _isSolved = false;
      _statusMessage = 'Computer is thinking...';
      _lastMove = null;
      _promotionMove = null;

      // Play the first computer move automatically
      _playComputerMove();
    } catch (e) {
      debugPrint('ERROR: Failed to initialize puzzle FEN: $e');
      _position = Chess.initial;
      _playerSide = _position.turn.opposite;
      _validMoves = makeLegalMoves(_position);
      _statusMessage = 'Unable to load puzzle.';
    }
  }

  void _playComputerMove() {
    if (_currentMoveIndex >= widget.puzzle.moves.length) return;

    final computerMoveUci = widget.puzzle.moves[_currentMoveIndex];
    try {
      final computerMove = NormalMove.fromUci(computerMoveUci);
      setState(() {
        _position = _position.play(computerMove);
        _lastMove = computerMove;
        _validMoves = makeLegalMoves(_position);
        _currentMoveIndex++;
        _statusMessage = 'Your turn';
      });
    } on FormatException catch (e) {
      debugPrint('Unable to parse computer move: $e');
      setState(() {
        _statusMessage = 'Invalid data for computer move.';
      });
    } on PlayException catch (e) {
      debugPrint('Illegal computer move $computerMoveUci: $e');
      setState(() {
        _statusMessage = 'Computer move could not be played.';
      });
    }
  }

  Future<void> _loadAttemptStatus() async {
    await widget.progressService.hasAttempted(widget.puzzle.id);
    setState(() {});
  }

  String get _nextMoveUci => widget.puzzle.moves[_currentMoveIndex];

  GameData get _gameData => GameData(
        playerSide:
            _playerSide == Side.white ? PlayerSide.white : PlayerSide.black,
        sideToMove: _position.turn,
        validMoves: _validMoves,
        isCheck: _position.isCheck,
        promotionMove: _promotionMove,
        onMove: (move, {bool? isDrop}) => _handleBoardMove(move),
        onPromotionSelection: _handlePromotionSelection,
      );

  void _handleBoardMove(NormalMove move) {
    if (_isSolved) return;
    if (_isPromotionPawnMove(move)) {
      setState(() {
        _promotionMove = move;
      });
      return;
    }

    final expected = _nextMoveUci;
    if (move.uci == expected) {
      _applyMove(move);
      if (_currentMoveIndex >= widget.puzzle.moves.length) {
        setState(() {
          _isSolved = true;
          _statusMessage = '✓ Puzzle solved!';
        });
        _markSolvedAndPop();
      } else {
        setState(() {
          _statusMessage = '✓ Correct! Computer to move...';
        });
        _playComputerResponseMove();
      }
    } else {
      // Store the position before the wrong move
      _previousPosition = _position;
      
      // Apply the move
      setState(() {
        _position = _position.play(move);
        _lastMove = move;
        _promotionMove = null;
        _validMoves = makeLegalMoves(_position);
        _statusMessage = '✗ Wrong move';
      });
      _markAttempted();
      
      // Undo the move after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _position = _previousPosition;
            _lastMove = null;
            _validMoves = makeLegalMoves(_position);
            _statusMessage = 'Try again';
          });
        }
      });
    }
  }

  void _handlePromotionSelection(Role? role) {
    if (role == null) {
      setState(() {
        _promotionMove = null;
      });
      return;
    }
    final pending = _promotionMove;
    if (pending == null) return;
    _handleBoardMove(pending.withPromotion(role));
  }

  bool _isPromotionPawnMove(NormalMove move) {
    final role = _position.board.roleAt(move.from);
    if (role != Role.pawn) return false;
    final reachingLastRank =
        (_position.turn == Side.white && move.to.rank == Rank.eighth) ||
            (_position.turn == Side.black && move.to.rank == Rank.first);
    return move.promotion == null && reachingLastRank;
  }

  void _applyMove(NormalMove move) {
    try {
      setState(() {
        _position = _position.play(move);
        _lastMove = move;
        _promotionMove = null;
        _validMoves = makeLegalMoves(_position);
        _currentMoveIndex++;
      });
    } on PlayException catch (e) {
      debugPrint('Failed to apply move ${move.uci}: $e');
    }
  }

  void _playComputerResponseMove() {
    if (_currentMoveIndex >= widget.puzzle.moves.length) return;

    final computerMoveUci = widget.puzzle.moves[_currentMoveIndex];
    try {
      final computerMove = NormalMove.fromUci(computerMoveUci);
      setState(() {
        _position = _position.play(computerMove);
        _lastMove = computerMove;
        _validMoves = makeLegalMoves(_position);
        _currentMoveIndex++;
        _statusMessage = 'Your turn';
      });
    } on FormatException catch (e) {
      debugPrint('Unable to parse computer move: $e');
      setState(() {
        _statusMessage = 'Invalid data for computer move.';
      });
    } on PlayException catch (e) {
      debugPrint('Illegal computer move $computerMoveUci: $e');
      setState(() {
        _statusMessage = 'Computer move could not be played.';
      });
    }
  }

  void _markSolvedAndPop() {
    widget.progressService
        .markSolved(widget.puzzle.id)
        .whenComplete(() =>
            widget.progressService.markAttempted(widget.puzzle.id).then((_) {
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                });
              }
            }));
  }

  void _markAttempted() {
    widget.progressService.markAttempted(widget.puzzle.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle #${widget.puzzleNumber}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          EvaluationBar(puzzle: widget.puzzle),
          Expanded(
            child: Center(
              child: ChessBoardWidget(
                fen: _position.fen,
                orientation: _playerSide,
                gameData: _gameData,
                lastMove: _lastMove,
              ),
            ),
          ),
          MoveHistory(
            moves: widget.puzzle.moves,
            currentMoveIndex: _currentMoveIndex,
          ),
          PuzzleControls(
            onReset: () {
              setState(() {
                _initializePosition();
              });
            },
              onGetHint: () {
              final hint = _nextMoveUci;
              final from = hint.substring(0, 2);
              final to = hint.substring(2, 4);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Try Moving: $from → $to',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isSolved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

