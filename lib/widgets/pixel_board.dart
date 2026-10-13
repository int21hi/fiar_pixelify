import 'package:flutter/material.dart';
import '../game/board_logic.dart';
import '../theme/retro_theme.dart';
import 'pixel_coin.dart';

class PixelBoard extends StatefulWidget {
  final List<List<int>> board;
  final List<CellPosition> winningCells;
  final int currentTurn;
  final bool isInteractive;
  final RetroThemePalette palette;
  final ValueChanged<int> onColumnSelected;

  const PixelBoard({
    super.key,
    required this.board,
    required this.winningCells,
    required this.currentTurn,
    required this.isInteractive,
    required this.palette,
    required this.onColumnSelected,
  });

  @override
  State<PixelBoard> createState() => _PixelBoardState();
}

class _PixelBoardState extends State<PixelBoard> {
  int? _hoveredCol;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
        final availHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;

        final maxColWidth = (availWidth - 32) / BoardLogic.cols;
        final maxRowHeight = (availHeight - 48) / BoardLogic.rows;
        final cellSize = maxColWidth < maxRowHeight
            ? maxColWidth.clamp(24.0, 56.0)
            : maxRowHeight.clamp(24.0, 56.0);

        final boardWidth = cellSize * BoardLogic.cols + 20;
        final boardHeight = cellSize * BoardLogic.rows + 20;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column selector indicator arrow row
              SizedBox(
                width: cellSize * BoardLogic.cols,
                height: 24,
                child: Row(
                  children: List.generate(BoardLogic.cols, (col) {
                    final isHovered = _hoveredCol == col;
                    final isAvailable =
                        widget.isInteractive &&
                        BoardLogic.isValidMove(widget.board, col);

                    return Expanded(
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isHovered && isAvailable ? 1.0 : 0.0,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: widget.currentTurn == BoardLogic.player1
                                ? widget.palette.player1
                                : widget.palette.player2,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Retro Board Frame
              Container(
                width: boardWidth,
                height: boardHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.palette.boardBackground,
                  border: Border.all(
                    color: widget.palette.border,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.palette.border.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                    const BoxShadow(
                      color: Colors.black87,
                      offset: Offset(4, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(BoardLogic.cols, (col) {
                    return Expanded(
                      child: _ColumnTapArea(
                        col: col,
                        board: widget.board,
                        winningCells: widget.winningCells,
                        palette: widget.palette,
                        cellSize: cellSize,
                        isInteractive: widget.isInteractive,
                        onHover: (hovered) {
                          setState(() {
                            _hoveredCol = hovered ? col : null;
                          });
                        },
                        onTap: () => widget.onColumnSelected(col),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnTapArea extends StatelessWidget {
  final int col;
  final List<List<int>> board;
  final List<CellPosition> winningCells;
  final RetroThemePalette palette;
  final double cellSize;
  final bool isInteractive;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _ColumnTapArea({
    required this.col,
    required this.board,
    required this.winningCells,
    required this.palette,
    required this.cellSize,
    required this.isInteractive,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canMove = isInteractive && BoardLogic.isValidMove(board, col);

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: canMove ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canMove ? onTap : null,
        child: Column(
          children: List.generate(BoardLogic.rows, (row) {
            final cellValue = board[row][col];
            final isWinning =
                winningCells.contains(CellPosition(row, col));

            return Expanded(
              child: Center(
                child: PixelCoin(
                  value: cellValue,
                  isWinningPiece: isWinning,
                  palette: palette,
                  size: cellSize * 0.85,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
