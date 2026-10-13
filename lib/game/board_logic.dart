class CellPosition {
  final int row;
  final int col;

  const CellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'CellPosition($row, $col)';
}

class BoardLogic {
  static const int rows = 6;
  static const int cols = 7;
  static const int empty = 0;
  static const int player1 = 1;
  static const int player2 = 2;

  static List<List<int>> createEmptyBoard() =>
      List.generate(rows, (_) => List.filled(cols, empty));

  static List<List<int>> cloneBoard(List<List<int>> source) =>
      source.map((row) => List<int>.from(row)).toList();

  static int? getLowestAvailableRow(List<List<int>> board, int col) {
    if (col < 0 || col >= cols) return null;
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r][col] == empty) {
        return r;
      }
    }
    return null;
  }

  static bool isValidMove(List<List<int>> board, int col) =>
      getLowestAvailableRow(board, col) != null;

  static List<int> getValidColumns(List<List<int>> board) {
    final List<int> valid = [];
    for (int c = 0; c < cols; c++) {
      if (board[0][c] == empty) {
        valid.add(c);
      }
    }
    return valid;
  }

  static bool isBoardFull(List<List<int>> board) {
    for (int c = 0; c < cols; c++) {
      if (board[0][c] == empty) {
        return false;
      }
    }
    return true;
  }

  static List<CellPosition>? checkWinningCells(
    List<List<int>> board,
    int player,
  ) {
    // 1. Horizontal check (-)
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c <= cols - 4; c++) {
        if (board[r][c] == player &&
            board[r][c + 1] == player &&
            board[r][c + 2] == player &&
            board[r][c + 3] == player) {
          return [
            CellPosition(r, c),
            CellPosition(r, c + 1),
            CellPosition(r, c + 2),
            CellPosition(r, c + 3),
          ];
        }
      }
    }

    // 2. Vertical check (|)
    for (int r = 0; r <= rows - 4; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == player &&
            board[r + 1][c] == player &&
            board[r + 2][c] == player &&
            board[r + 3][c] == player) {
          return [
            CellPosition(r, c),
            CellPosition(r + 1, c),
            CellPosition(r + 2, c),
            CellPosition(r + 3, c),
          ];
        }
      }
    }

    // 3. Diagonal Down-Right (\)
    for (int r = 0; r <= rows - 4; r++) {
      for (int c = 0; c <= cols - 4; c++) {
        if (board[r][c] == player &&
            board[r + 1][c + 1] == player &&
            board[r + 2][c + 2] == player &&
            board[r + 3][c + 3] == player) {
          return [
            CellPosition(r, c),
            CellPosition(r + 1, c + 1),
            CellPosition(r + 2, c + 2),
            CellPosition(r + 3, c + 3),
          ];
        }
      }
    }

    // 4. Diagonal Up-Right (/)
    for (int r = 3; r < rows; r++) {
      for (int c = 0; c <= cols - 4; c++) {
        if (board[r][c] == player &&
            board[r - 1][c + 1] == player &&
            board[r - 2][c + 2] == player &&
            board[r - 3][c + 3] == player) {
          return [
            CellPosition(r, c),
            CellPosition(r - 1, c + 1),
            CellPosition(r - 2, c + 2),
            CellPosition(r - 3, c + 3),
          ];
        }
      }
    }

    return null;
  }

  static int? checkWinner(List<List<int>> board) {
    if (checkWinningCells(board, player1) != null) return player1;
    if (checkWinningCells(board, player2) != null) return player2;
    return null;
  }
}
