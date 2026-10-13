import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai/ai_easy.dart';
import 'ai/ai_minimax.dart';
import 'ai/ai_normal.dart';
import 'board_logic.dart';
import 'game_state.dart';
import 'stats_cubit.dart';

class GameController extends Cubit<GameState> {
  final StatsCubit? statsCubit;
  Timer? _aiTimer;

  GameController({this.statsCubit}) : super(GameState.initial());

  @override
  Future<void> close() {
    _aiTimer?.cancel();
    return super.close();
  }

  void resetGame() {
    _aiTimer?.cancel();
    emit(
      state.copyWith(
        board: BoardLogic.createEmptyBoard(),
        currentTurn: BoardLogic.player1,
        status: GameStatus.playing,
        clearWinner: true,
        winningCells: const [],
        moveHistory: const [],
        isAiThinking: false,
        clearLastMove: true,
        clearErrorMessage: true,
      ),
    );
  }

  void setGameMode(GameMode mode) {
    if (state.gameMode == mode) return;
    _aiTimer?.cancel();
    emit(
      state.copyWith(
        gameMode: mode,
        board: BoardLogic.createEmptyBoard(),
        currentTurn: BoardLogic.player1,
        status: GameStatus.playing,
        clearWinner: true,
        winningCells: const [],
        moveHistory: const [],
        isAiThinking: false,
        clearLastMove: true,
        clearErrorMessage: true,
      ),
    );
  }

  void setDifficulty(AIDifficulty difficulty) {
    if (state.difficulty == difficulty) return;
    emit(state.copyWith(difficulty: difficulty));
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearErrorMessage: true));
    }
  }

  void makeMove(int col) {
    if (state.isGameOver) {
      emit(
        state.copyWith(
          errorMessage: 'Game is over! Press Restart to play again.',
        ),
      );
      return;
    }

    if (state.isAiThinking) {
      emit(state.copyWith(errorMessage: 'Wait! AI is calculating its move.'));
      return;
    }

    if (state.gameMode == GameMode.ai &&
        state.currentTurn == BoardLogic.player2) {
      emit(state.copyWith(errorMessage: 'Wait for your turn!'));
      return;
    }

    final row = BoardLogic.getLowestAvailableRow(state.board, col);
    if (row == null) {
      emit(state.copyWith(errorMessage: 'Column $col is already full!'));
      return;
    }

    _applyMove(col, row, state.currentTurn);
  }

  void _applyMove(int col, int row, int player) {
    final newBoard = BoardLogic.cloneBoard(state.board);
    newBoard[row][col] = player;

    final move = Move(player: player, row: row, col: col);
    final newHistory = List<Move>.from(state.moveHistory)..add(move);

    // Check for victory
    final winningCells = BoardLogic.checkWinningCells(newBoard, player);
    if (winningCells != null) {
      emit(
        state.copyWith(
          board: newBoard,
          status: GameStatus.won,
          winner: player,
          winningCells: winningCells,
          moveHistory: newHistory,
          lastMove: move,
          isAiThinking: false,
          clearErrorMessage: true,
        ),
      );
      statsCubit?.recordGameEnd(
        mode: state.gameMode,
        difficulty: state.difficulty,
        winner: player,
      );
      return;
    }

    // Check for draw
    if (BoardLogic.isBoardFull(newBoard)) {
      emit(
        state.copyWith(
          board: newBoard,
          status: GameStatus.draw,
          clearWinner: true,
          winningCells: const [],
          moveHistory: newHistory,
          lastMove: move,
          isAiThinking: false,
          clearErrorMessage: true,
        ),
      );
      statsCubit?.recordGameEnd(
        mode: state.gameMode,
        difficulty: state.difficulty,
        winner: null,
      );
      return;
    }

    // Next turn
    final nextTurn =
        (player == BoardLogic.player1) ? BoardLogic.player2 : BoardLogic.player1;

    emit(
      state.copyWith(
        board: newBoard,
        currentTurn: nextTurn,
        moveHistory: newHistory,
        lastMove: move,
        isAiThinking: false,
        clearErrorMessage: true,
      ),
    );

    // If vs AI and it's AI's turn, schedule AI move
    if (state.gameMode == GameMode.ai && nextTurn == BoardLogic.player2) {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() {
    emit(state.copyWith(isAiThinking: true));
    _aiTimer?.cancel();
    _aiTimer = Timer(const Duration(milliseconds: 380), () {
      if (isClosed || state.isGameOver) return;

      int chosenCol = -1;
      switch (state.difficulty) {
        case AIDifficulty.easy:
          chosenCol = AIEasy.chooseMove(state.board, BoardLogic.player2);
          break;
        case AIDifficulty.normal:
          chosenCol = AINormal.chooseMove(state.board, BoardLogic.player2);
          break;
        case AIDifficulty.hard:
          chosenCol = AIMinimax.chooseMove(state.board, BoardLogic.player2);
          break;
      }

      if (chosenCol == -1) {
        emit(
          state.copyWith(
            isAiThinking: false,
            errorMessage: 'AI could not find a valid move.',
          ),
        );
        return;
      }

      final row = BoardLogic.getLowestAvailableRow(state.board, chosenCol);
      if (row == null) {
        emit(
          state.copyWith(
            isAiThinking: false,
            errorMessage: 'AI chose full column.',
          ),
        );
        return;
      }

      _applyMove(chosenCol, row, BoardLogic.player2);
    });
  }

  void undoMove() {
    if (!state.canUndo) {
      emit(state.copyWith(errorMessage: 'Cannot undo move at this time.'));
      return;
    }

    _aiTimer?.cancel();

    int movesToUndo = 1;
    if (state.gameMode == GameMode.ai) {
      // In AI mode, if the last move was AI, undo AI move AND the human move before it
      final last = state.moveHistory.last;
      if (last.player == BoardLogic.player2 && state.moveHistory.length >= 2) {
        movesToUndo = 2;
      }
    }

    final newHistory = List<Move>.from(state.moveHistory);
    final newBoard = BoardLogic.cloneBoard(state.board);

    for (int i = 0; i < movesToUndo && newHistory.isNotEmpty; i++) {
      final removed = newHistory.removeLast();
      newBoard[removed.row][removed.col] = BoardLogic.empty;
    }

    final newTurn = newHistory.isEmpty
        ? BoardLogic.player1
        : (newHistory.last.player == BoardLogic.player1
            ? BoardLogic.player2
            : BoardLogic.player1);

    emit(
      state.copyWith(
        board: newBoard,
        currentTurn: newTurn,
        moveHistory: newHistory,
        status: GameStatus.playing,
        clearWinner: true,
        winningCells: const [],
        isAiThinking: false,
        lastMove: newHistory.isNotEmpty ? newHistory.last : null,
        clearLastMove: newHistory.isEmpty,
        clearErrorMessage: true,
      ),
    );
  }
}
