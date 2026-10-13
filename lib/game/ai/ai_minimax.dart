import 'dart:math';
import '../board_logic.dart';

class AIMinimax {
  static const int maxDepth = 5;
  static const int winScore = 1000000;
  static const List<int> _preferredOrder = [3, 2, 4, 1, 5, 0, 6];

  static int chooseMove(List<List<int>> board, int aiPlayer) {
    final validCols = BoardLogic.getValidColumns(board);
    if (validCols.isEmpty) return -1;
    if (validCols.length == 1) return validCols.first;

    // Check immediate win / block first for lightning quick response
    final opponent =
        (aiPlayer == BoardLogic.player1) ? BoardLogic.player2 : BoardLogic.player1;

    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;
      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = aiPlayer;
      if (BoardLogic.checkWinningCells(clone, aiPlayer) != null) {
        return col;
      }
    }

    for (final col in validCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col);
      if (row == null) continue;
      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = opponent;
      if (BoardLogic.checkWinningCells(clone, opponent) != null) {
        return col;
      }
    }

    int bestScore = -100000000;
    int bestCol = validCols.first;
    int alpha = -100000000;
    const int beta = 100000000;

    // Ordered moves for optimal alpha-beta pruning
    final orderedCols = _orderColumns(validCols);

    for (final col in orderedCols) {
      final row = BoardLogic.getLowestAvailableRow(board, col)!;
      final clone = BoardLogic.cloneBoard(board);
      clone[row][col] = aiPlayer;

      final score = _minimax(
        clone,
        maxDepth - 1,
        alpha,
        beta,
        false,
        aiPlayer,
        opponent,
      );

      if (score > bestScore) {
        bestScore = score;
        bestCol = col;
      }
      alpha = max(alpha, bestScore);
      if (alpha >= beta) {
        break;
      }
    }

    return bestCol;
  }

  static int _minimax(
    List<List<int>> board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    int aiPlayer,
    int opponent,
  ) {
    final aiWon = BoardLogic.checkWinningCells(board, aiPlayer) != null;
    if (aiWon) return winScore + depth;

    final oppWon = BoardLogic.checkWinningCells(board, opponent) != null;
    if (oppWon) return -winScore - depth;

    final validCols = BoardLogic.getValidColumns(board);
    if (validCols.isEmpty) return 0; // Draw

    if (depth == 0) {
      return _evaluateBoard(board, aiPlayer, opponent);
    }

    final orderedCols = _orderColumns(validCols);

    if (isMaximizing) {
      int maxEval = -100000000;
      for (final col in orderedCols) {
        final row = BoardLogic.getLowestAvailableRow(board, col)!;
        board[row][col] = aiPlayer;
        final eval = _minimax(
          board,
          depth - 1,
          alpha,
          beta,
          false,
          aiPlayer,
          opponent,
        );
        board[row][col] = BoardLogic.empty;

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 100000000;
      for (final col in orderedCols) {
        final row = BoardLogic.getLowestAvailableRow(board, col)!;
        board[row][col] = opponent;
        final eval = _minimax(
          board,
          depth - 1,
          alpha,
          beta,
          true,
          aiPlayer,
          opponent,
        );
        board[row][col] = BoardLogic.empty;

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static List<int> _orderColumns(List<int> validCols) {
    final List<int> ordered = [];
    for (final c in _preferredOrder) {
      if (validCols.contains(c)) ordered.add(c);
    }
    return ordered;
  }

  static int _evaluateBoard(
    List<List<int>> board,
    int aiPlayer,
    int opponent,
  ) {
    int score = 0;

    // 1. Center column preference
    final centerCol = BoardLogic.cols ~/ 2;
    int centerAiCount = 0;
    for (int r = 0; r < BoardLogic.rows; r++) {
      if (board[r][centerCol] == aiPlayer) centerAiCount++;
    }
    score += centerAiCount * 6;

    // 2. Horizontal windows
    for (int r = 0; r < BoardLogic.rows; r++) {
      for (int c = 0; c <= BoardLogic.cols - 4; c++) {
        final window = [
          board[r][c],
          board[r][c + 1],
          board[r][c + 2],
          board[r][c + 3],
        ];
        score += _evaluateWindow(window, aiPlayer, opponent);
      }
    }

    // 3. Vertical windows
    for (int c = 0; c < BoardLogic.cols; c++) {
      for (int r = 0; r <= BoardLogic.rows - 4; r++) {
        final window = [
          board[r][c],
          board[r + 1][c],
          board[r + 2][c],
          board[r + 3][c],
        ];
        score += _evaluateWindow(window, aiPlayer, opponent);
      }
    }

    // 4. Diagonal Down-Right
    for (int r = 0; r <= BoardLogic.rows - 4; r++) {
      for (int c = 0; c <= BoardLogic.cols - 4; c++) {
        final window = [
          board[r][c],
          board[r + 1][c + 1],
          board[r + 2][c + 2],
          board[r + 3][c + 3],
        ];
        score += _evaluateWindow(window, aiPlayer, opponent);
      }
    }

    // 5. Diagonal Up-Right
    for (int r = 3; r < BoardLogic.rows; r++) {
      for (int c = 0; c <= BoardLogic.cols - 4; c++) {
        final window = [
          board[r][c],
          board[r - 1][c + 1],
          board[r - 2][c + 2],
          board[r - 3][c + 3],
        ];
        score += _evaluateWindow(window, aiPlayer, opponent);
      }
    }

    return score;
  }

  static int _evaluateWindow(
    List<int> window,
    int aiPlayer,
    int opponent,
  ) {
    int score = 0;
    int aiCount = 0;
    int oppCount = 0;
    int emptyCount = 0;

    for (final cell in window) {
      if (cell == aiPlayer) {
        aiCount++;
      } else if (cell == opponent) {
        oppCount++;
      } else {
        emptyCount++;
      }
    }

    if (aiCount == 4) {
      score += 100000;
    } else if (aiCount == 3 && emptyCount == 1) {
      score += 120;
    } else if (aiCount == 2 && emptyCount == 2) {
      score += 12;
    }

    if (oppCount == 3 && emptyCount == 1) {
      score -= 220;
    } else if (oppCount == 2 && emptyCount == 2) {
      score -= 18;
    }

    return score;
  }
}
