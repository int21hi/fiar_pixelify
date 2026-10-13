import 'dart:math';
import '../board_logic.dart';

class AIEasy {
  static final Random _random = Random();

  static int chooseMove(List<List<int>> board, int aiPlayer) {
    final validCols = BoardLogic.getValidColumns(board);
    if (validCols.isEmpty) return -1;

    // 1. Immediate win check
    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;

      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = aiPlayer;
      if (BoardLogic.checkWinningCells(clone, aiPlayer) != null) {
        return col;
      }
    }

    // 2. Otherwise pick randomly
    return validCols[_random.nextInt(validCols.length)];
  }
}
