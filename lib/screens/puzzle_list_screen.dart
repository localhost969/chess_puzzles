import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../models/puzzle.dart';
import '../services/puzzle_repository.dart';
import '../services/progress_service.dart';
import '../widgets/chess_board.dart';
import 'single_puzzle_screen.dart';

class PuzzleListScreen extends StatefulWidget {
  final PuzzleRepository repository;
  final ProgressService progressService;

  const PuzzleListScreen({
    super.key,
    required this.repository,
    required this.progressService,
  });

  @override
  State<PuzzleListScreen> createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  late Future<List<Puzzle>> _futurePuzzles;
  Set<String> _solvedIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futurePuzzles = widget.repository.loadPuzzles();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final solved = await widget.progressService.getSolvedIds();
    setState(() {
      _solvedIds = solved;
    });
  }

  Future<void> _refreshProgress() async {
    await _loadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Puzzles'),
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: _futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final puzzles = snapshot.data ?? [];
          final solvedCount =
              puzzles.where((p) => _solvedIds.contains(p.id)).length;
          final remainingCount = puzzles.length - solvedCount;
          final platform = Theme.of(context).platform;
          final ScrollPhysics scrollPhysics =
              platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
                  ? const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    )
                  : const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    );

          return RefreshIndicator(
            onRefresh: () async {
              await _refreshProgress();
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatChip(label: 'Solved', value: solvedCount),
                      _StatChip(label: 'Remaining', value: remainingCount),
                      _StatChip(label: 'Total', value: puzzles.length),
                    ],
                  ),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const _SmoothScrollBehavior(),
                    child: Builder(builder: (context) {
                      final theme = Theme.of(context);
                      final scrollbarTheme = ScrollbarThemeData(
                        thumbColor:
                            WidgetStateProperty.all(theme.colorScheme.primary),
                        thickness: WidgetStateProperty.all(6.0),
                        radius: const Radius.circular(4),
                        trackColor: WidgetStateProperty.all(
                          theme.colorScheme.surface.withValues(alpha: 0.02),
                        ),
                        // Min thumb visibility for better accessibility
                        crossAxisMargin: 2.0,
                      );

                      return ScrollbarTheme(
                        data: scrollbarTheme,
                        child: Scrollbar(
                          controller: _scrollController,
                          thickness: 6,
                          radius: const Radius.circular(4),
                          interactive: true,
                          thumbVisibility: true,
                          child: ListView.builder(
                        controller: _scrollController,
                        physics: scrollPhysics,
                        itemCount: puzzles.length,
                        itemBuilder: (context, index) {
                          final p = puzzles[index];
                          final puzzleNumber = index + 1;
                          final solved = _solvedIds.contains(p.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: _PuzzleCard(
                              puzzle: p,
                              puzzleNumber: puzzleNumber,
                              solved: solved,
                              onTap: () async {
                                final updated = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SinglePuzzleScreen(
                                      puzzle: p,
                                      puzzleNumber: puzzleNumber,
                                      progressService: widget.progressService,
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  _refreshProgress();
                                }
                              },
                            ),
                          );
                        },
                      ), // close ListView.builder
                    ), // close Scrollbar
                  ); // close ScrollbarTheme (returned by builder)
                    }), // close Builder
                  ), // close ScrollConfiguration
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Chip(
      backgroundColor: color.withValues(alpha: 0.15),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

final GameData _previewGameData = GameData(
  playerSide: PlayerSide.white,
  sideToMove: Side.white,
  validMoves: IMap(const {}),
  isCheck: false,
  promotionMove: null,
  onMove: (move, {isDrop}) {},
  onPromotionSelection: (_) {},
);

const ChessboardSettings _previewBoardSettings = ChessboardSettings(
  enableCoordinates: false,
);

class _PuzzleCard extends StatelessWidget {
  final Puzzle puzzle;
  final int puzzleNumber;
  final bool solved;
  final VoidCallback onTap;

  const _PuzzleCard({
    required this.puzzle,
    required this.puzzleNumber,
    required this.solved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewThemes = puzzle.themes.take(2).toList(growable: false);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.cardColor,
              border: Border.all(
                color: theme.dividerColor.withValues(
                  alpha: solved ? 0.5 : 0.2,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RepaintBoundary(
                      child: IgnorePointer(
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: ChessBoardWidget(
                            fen: puzzle.fen,
                            orientation: Side.white,
                            gameData: _previewGameData,
                            settings: _previewBoardSettings,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Puzzle $puzzleNumber'.toUpperCase(),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: previewThemes
                              .map((themeLabel) => _ThemeBadge(text: themeLabel))
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.bodySmall!.copyWith(
                                color: solved
                                    ? theme.colorScheme.primary
                                    : Colors.grey[600],
                                fontWeight:
                                    solved ? FontWeight.w600 : FontWeight.w400,
                              ),
                          child: Text(solved ? 'Solved' : 'Unsolved'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeBadge extends StatelessWidget {
  final String text;

  const _ThemeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  const _SmoothScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Remove glow for a cleaner professional look
  }
}
