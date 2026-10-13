import 'package:flutter_test/flutter_test.dart';
import 'package:spin_game/game/ai/ai_easy.dart';
import 'package:spin_game/game/ai/ai_minimax.dart';
import 'package:spin_game/game/ai/ai_normal.dart';
import 'package:spin_game/game/board_logic.dart';

void main() {
  group('BoardLogic Tests', () {
    test('Empty board has correct dimensions and zeroes', () {
      final board = BoardLogic.createEmptyBoard();
      expect(board.length, BoardLogic.rows);
      for (final row in board) {
        expect(row.length, BoardLogic.cols);
        expect(row.every((cell) => cell == BoardLogic.empty), isTrue);
      }
    });

    test('Gravity places piece at lowest available row', () {
      final board = BoardLogic.createEmptyBoard();
      final lowest1 = BoardLogic.getLowestAvailableRow(board, 3);
      expect(lowest1, 5); // Row 5 is the bottom row

      board[5][3] = BoardLogic.player1;
      final lowest2 = BoardLogic.getLowestAvailableRow(board, 3);
      expect(lowest2, 4);

      for (int r = 4; r >= 0; r--) {
        board[r][3] = BoardLogic.player2;
      }
      expect(BoardLogic.getLowestAvailableRow(board, 3), isNull);
      expect(BoardLogic.isValidMove(board, 3), isFalse);
    });

    test('Detects horizontal win', () {
      final board = BoardLogic.createEmptyBoard();
      // Player 1 places 4 in row 5, columns 1 to 4
      for (int c = 1; c <= 4; c++) {
        board[5][c] = BoardLogic.player1;
      }

      final winning = BoardLogic.checkWinningCells(board, BoardLogic.player1);
      expect(winning, isNotNull);
      expect(winning!.length, 4);
      expect(
        winning,
        containsAll([
          const CellPosition(5, 1),
          const CellPosition(5, 2),
          const CellPosition(5, 3),
          const CellPosition(5, 4),
        ]),
      );
      expect(BoardLogic.checkWinner(board), BoardLogic.player1);
    });

    test('Detects vertical win', () {
      final board = BoardLogic.createEmptyBoard();
      // Player 2 places 4 in col 2, rows 5 down to 2
      for (int r = 5; r >= 2; r--) {
        board[r][2] = BoardLogic.player2;
      }

      final winning = BoardLogic.checkWinningCells(board, BoardLogic.player2);
      expect(winning, isNotNull);
      expect(BoardLogic.checkWinner(board), BoardLogic.player2);
    });

    test('Detects diagonal down-right win', () {
      final board = BoardLogic.createEmptyBoard();
      board[2][1] = BoardLogic.player1;
      board[3][2] = BoardLogic.player1;
      board[4][3] = BoardLogic.player1;
      board[5][4] = BoardLogic.player1;

      final winning = BoardLogic.checkWinningCells(board, BoardLogic.player1);
      expect(winning, isNotNull);
      expect(BoardLogic.checkWinner(board), BoardLogic.player1);
    });

    test('Detects diagonal up-right win', () {
      final board = BoardLogic.createEmptyBoard();
      board[5][1] = BoardLogic.player2;
      board[4][2] = BoardLogic.player2;
      board[3][3] = BoardLogic.player2;
      board[2][4] = BoardLogic.player2;

      final winning = BoardLogic.checkWinningCells(board, BoardLogic.player2);
      expect(winning, isNotNull);
      expect(BoardLogic.checkWinner(board), BoardLogic.player2);
    });

    test('Full board detection', () {
      final board = BoardLogic.createEmptyBoard();
      expect(BoardLogic.isBoardFull(board), isFalse);

      for (int r = 0; r < BoardLogic.rows; r++) {
        for (int c = 0; c < BoardLogic.cols; c++) {
          board[r][c] = (r + c) % 2 == 0 ? BoardLogic.player1 : BoardLogic.player2;
        }
      }
      expect(BoardLogic.isBoardFull(board), isTrue);
    });
  });

  group('AI Logic Tests', () {
    test('Easy AI chooses immediate win if available', () {
      final board = BoardLogic.createEmptyBoard();
      // AI (Player 2) has 3 in a row horizontally at row 5, cols 0, 1, 2
      board[5][0] = BoardLogic.player2;
      board[5][1] = BoardLogic.player2;
      board[5][2] = BoardLogic.player2;

      final move = AIEasy.chooseMove(board, BoardLogic.player2);
      expect(move, 3); // Must pick column 3 to win
    });

    test('Normal AI blocks opponent immediate win', () {
      final board = BoardLogic.createEmptyBoard();
      // Opponent (Player 1) has 3 in a row horizontally at row 5, cols 1, 2, 3
      board[5][1] = BoardLogic.player1;
      board[5][2] = BoardLogic.player1;
      board[5][3] = BoardLogic.player1;

      final move = AINormal.chooseMove(board, BoardLogic.player2);
      // AI must block either col 0 or col 4
      expect(move == 0 || move == 4, isTrue);
    });

    test('Minimax AI blocks opponent vertical win', () {
      final board = BoardLogic.createEmptyBoard();
      // Opponent (Player 1) has 3 in col 3, rows 5, 4, 3
      board[5][3] = BoardLogic.player1;
      board[4][3] = BoardLogic.player1;
      board[3][3] = BoardLogic.player1;

      final move = AIMinimax.chooseMove(board, BoardLogic.player2);
      // Must drop in col 3 to block!
      expect(move, 3);
    });
  });
}
