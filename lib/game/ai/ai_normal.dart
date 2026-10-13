import 'dart:math';
import '../board_logic.dart';

class AINormal {
  static final Random _random = Random();
  static const List<int> _preferredOrder = [3, 2, 4, 1, 5, 0, 6];

  static int chooseMove(List<List<int>> board, int aiPlayer) {
    final validCols = BoardLogic.getValidColumns(board);
    if (validCols.isEmpty) return -1;
    final opponent =
        (aiPlayer == BoardLogic.player1) ? BoardLogic.player2 : BoardLogic.player1;

    // 1. Can AI win immediately?
    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;

      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = aiPlayer;
      if (BoardLogic.checkWinningCells(clone, aiPlayer) != null) {
        return col;
      }
    }

    // 2. Can opponent win immediately? Block them!
    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;

      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = opponent;
      if (BoardLogic.checkWinningCells(clone, opponent) != null) {
        return col;
      }
    }

    // 3. Filter out moves that directly allow opponent to win right above us
    final safeCols = <int>[];
    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;

      // Check if placing here opens the row above for an immediate opponent win
      if (row > 0) {
        final clone = BoardLogic.cloneBoard(board);
        clone[row][col] = aiPlayer;
        clone[row - 1][col] = opponent;
        if (BoardLogic.checkWinningCells(clone, opponent) != null) {
          // Dangerous move!
          continue;
        }
      }
      safeCols.add(col);
    }

    final candidateCols = safeCols.isNotEmpty ? safeCols : validCols;

    // 4. Pick best column based on center proximity
    for (final preferredCol in _preferredOrder) {
      if (candidateCols.contains(preferredCol)) {
        // Small chance of exploring adjacent to make it feel human/normal
        if (_random.nextDouble() < 0.85) {
          return preferredCol;
        }
      }
    }

    return candidateCols[_random.nextInt(candidateCols.length)];
  }
}
