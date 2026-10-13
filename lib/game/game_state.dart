import 'board_logic.dart';

enum GameMode {
  pvp,
  ai,
}

enum AIDifficulty {
  easy,
  normal,
  hard,
}

enum GameStatus {
  playing,
  won,
  draw,
}

class Move {
  final int player;
  final int row;
  final int col;

  const Move({
    required this.player,
    required this.row,
    required this.col,
  });

  @override
  String toString() => 'Move(player: $player, row: $row, col: $col)';
}

class GameState {
  final List<List<int>> board;
  final int currentTurn;
  final GameMode gameMode;
  final AIDifficulty difficulty;
  final GameStatus status;
  final int? winner;
  final List<CellPosition> winningCells;
  final List<Move> moveHistory;
  final bool isAiThinking;
  final Move? lastMove;
  final String? errorMessage;

  const GameState({
    required this.board,
    required this.currentTurn,
    required this.gameMode,
    required this.difficulty,
    required this.status,
    this.winner,
    this.winningCells = const [],
    this.moveHistory = const [],
    this.isAiThinking = false,
    this.lastMove,
    this.errorMessage,
  });

  factory GameState.initial() => GameState(
        board: BoardLogic.createEmptyBoard(),
        currentTurn: BoardLogic.player1,
        gameMode: GameMode.ai,
        difficulty: AIDifficulty.normal,
        status: GameStatus.playing,
        winner: null,
        winningCells: const [],
        moveHistory: const [],
        isAiThinking: false,
        lastMove: null,
        errorMessage: null,
      );

  bool get isGameOver => status == GameStatus.won || status == GameStatus.draw;
  bool get isPlayer1Turn => currentTurn == BoardLogic.player1;
  bool get isAiTurn =>
      gameMode == GameMode.ai && currentTurn == BoardLogic.player2 && !isGameOver;
  bool get canUndo => moveHistory.isNotEmpty && !isAiThinking && !isGameOver;

  GameState copyWith({
    List<List<int>>? board,
    int? currentTurn,
    GameMode? gameMode,
    AIDifficulty? difficulty,
    GameStatus? status,
    int? winner,
    bool clearWinner = false,
    List<CellPosition>? winningCells,
    List<Move>? moveHistory,
    bool? isAiThinking,
    Move? lastMove,
    bool clearLastMove = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      winner: clearWinner ? null : (winner ?? this.winner),
      winningCells: winningCells ?? this.winningCells,
      moveHistory: moveHistory ?? this.moveHistory,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
