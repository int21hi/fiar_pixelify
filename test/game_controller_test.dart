import 'package:flutter_test/flutter_test.dart';
import 'package:spin_game/game/board_logic.dart';
import 'package:spin_game/game/game_controller.dart';
import 'package:spin_game/game/game_state.dart';

void main() {
  group('GameController Tests', () {
    test('Initial state is correct', () {
      final controller = GameController();
      expect(controller.state.currentTurn, BoardLogic.player1);
      expect(controller.state.gameMode, GameMode.ai);
      expect(controller.state.difficulty, AIDifficulty.normal);
      expect(controller.state.status, GameStatus.playing);
      expect(controller.state.winner, isNull);
      expect(controller.state.moveHistory, isEmpty);
      controller.close();
    });

    test('Pass & Play (PvP) alternates turns and allows undo', () {
      final controller = GameController();
      controller.setGameMode(GameMode.pvp);

      // Player 1 drops in col 3
      controller.makeMove(3);
      expect(controller.state.board[5][3], BoardLogic.player1);
      expect(controller.state.currentTurn, BoardLogic.player2);
      expect(controller.state.moveHistory.length, 1);

      // Player 2 drops in col 3
      controller.makeMove(3);
      expect(controller.state.board[4][3], BoardLogic.player2);
      expect(controller.state.currentTurn, BoardLogic.player1);
      expect(controller.state.moveHistory.length, 2);

      // Undo last move
      controller.undoMove();
      expect(controller.state.board[4][3], BoardLogic.empty);
      expect(controller.state.currentTurn, BoardLogic.player2);
      expect(controller.state.moveHistory.length, 1);

      // Reset
      controller.resetGame();
      expect(controller.state.board[5][3], BoardLogic.empty);
      expect(controller.state.currentTurn, BoardLogic.player1);
      expect(controller.state.moveHistory, isEmpty);

      controller.close();
    });

    test('PvP win detection updates status to won and identifies winningCells', () {
      final controller = GameController();
      controller.setGameMode(GameMode.pvp);

      // P1: col 0, P2: col 1
      controller.makeMove(0);
      controller.makeMove(1);

      // P1: col 0, P2: col 1
      controller.makeMove(0);
      controller.makeMove(1);

      // P1: col 0, P2: col 1
      controller.makeMove(0);
      controller.makeMove(1);

      // P1: col 0 (4th piece in col 0 => P1 vertical win!)
      controller.makeMove(0);

      expect(controller.state.status, GameStatus.won);
      expect(controller.state.winner, BoardLogic.player1);
      expect(controller.state.winningCells.length, 4);

      controller.close();
    });

    test('AI mode triggers AI response, resets isAiThinking, and allows next player move', () async {
      final controller = GameController();
      expect(controller.state.gameMode, GameMode.ai);

      // Player 1 plays column 3
      controller.makeMove(3);
      expect(controller.state.currentTurn, BoardLogic.player2);
      expect(controller.state.isAiThinking, isTrue);

      // Wait for AI timer (380ms + buffer)
      await Future.delayed(const Duration(milliseconds: 500));

      // AI should have played
      expect(controller.state.currentTurn, BoardLogic.player1);
      expect(controller.state.isAiThinking, isFalse);
      expect(controller.state.moveHistory.length, 2);

      // Player 1 can now play second move
      controller.makeMove(3);
      expect(controller.state.moveHistory.length, 3);
      expect(controller.state.currentTurn, BoardLogic.player2);

      controller.close();
    });
  });
}
