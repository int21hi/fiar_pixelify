import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/board_logic.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../../game/settings_cubit.dart';
import '../../theme/retro_theme.dart';
import '../../widgets/pixel_board.dart';
import '../../widgets/retro_button.dart';

class GameTab extends StatelessWidget {
  const GameTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final palette = settings.palette;
    final gameState = context.watch<GameController>().state;
    final controller = context.read<GameController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          children: [
            // Top Mode and Difficulty Selectors
            _ModeAndDifficultySelector(
              state: gameState,
              palette: palette,
              onModeChanged: controller.setGameMode,
              onDifficultyChanged: controller.setDifficulty,
            ),
            const SizedBox(height: 10),

            // Turn & Status Banner
            _StatusBanner(
              state: gameState,
              palette: palette,
            ),
            const SizedBox(height: 8),

            // Error message using SelectableText.rich per rule
            if (gameState.errorMessage != null) ...[
              _ErrorMessageView(
                message: gameState.errorMessage!,
              ),
              const SizedBox(height: 8),
            ],

            // Game Board Area
            Expanded(
              child: PixelBoard(
                board: gameState.board,
                winningCells: gameState.winningCells,
                currentTurn: gameState.currentTurn,
                isInteractive: !gameState.isGameOver &&
                    !gameState.isAiThinking &&
                    (!gameState.isAiTurn),
                palette: palette,
                onColumnSelected: controller.makeMove,
              ),
            ),
            const SizedBox(height: 10),

            // Game Controls (Restart, Undo)
            _GameControls(
              state: gameState,
              palette: palette,
              onRestart: controller.resetGame,
              onUndo: controller.undoMove,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _ModeAndDifficultySelector extends StatelessWidget {
  final GameState state;
  final RetroThemePalette palette;
  final ValueChanged<GameMode> onModeChanged;
  final ValueChanged<AIDifficulty> onDifficultyChanged;

  const _ModeAndDifficultySelector({
    required this.state,
    required this.palette,
    required this.onModeChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Selector: 1 vs AI / 2-Player Local
        Row(
          children: [
            Expanded(
              child: RetroButton(
                label: 'VS AI',
                icon: Icons.smart_toy_outlined,
                isSelected: state.gameMode == GameMode.ai,
                color: state.gameMode == GameMode.ai
                    ? palette.surfaceLight
                    : palette.surface,
                borderColor: state.gameMode == GameMode.ai
                    ? palette.border
                    : Colors.white12,
                textColor: state.gameMode == GameMode.ai
                    ? palette.border
                    : Colors.white60,
                onPressed: () => onModeChanged(GameMode.ai),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RetroButton(
                label: '2-PLAYER',
                icon: Icons.people_outline,
                isSelected: state.gameMode == GameMode.pvp,
                color: state.gameMode == GameMode.pvp
                    ? palette.surfaceLight
                    : palette.surface,
                borderColor: state.gameMode == GameMode.pvp
                    ? palette.border
                    : Colors.white12,
                textColor: state.gameMode == GameMode.pvp
                    ? palette.border
                    : Colors.white60,
                onPressed: () => onModeChanged(GameMode.pvp),
              ),
            ),
          ],
        ),

        // Difficulty Selector (if vs AI)
        if (state.gameMode == GameMode.ai) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  label: 'EASY',
                  fontSize: 9,
                  isSelected: state.difficulty == AIDifficulty.easy,
                  color: state.difficulty == AIDifficulty.easy
                      ? const Color(0xFF1B4D1B)
                      : palette.surface,
                  borderColor: state.difficulty == AIDifficulty.easy
                      ? const Color(0xFF39FF14)
                      : Colors.white12,
                  textColor: state.difficulty == AIDifficulty.easy
                      ? const Color(0xFF39FF14)
                      : Colors.white60,
                  onPressed: () => onDifficultyChanged(AIDifficulty.easy),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RetroButton(
                  label: 'NORMAL',
                  fontSize: 9,
                  isSelected: state.difficulty == AIDifficulty.normal,
                  color: state.difficulty == AIDifficulty.normal
                      ? const Color(0xFF4A3800)
                      : palette.surface,
                  borderColor: state.difficulty == AIDifficulty.normal
                      ? const Color(0xFFFFD214)
                      : Colors.white12,
                  textColor: state.difficulty == AIDifficulty.normal
                      ? const Color(0xFFFFD214)
                      : Colors.white60,
                  onPressed: () => onDifficultyChanged(AIDifficulty.normal),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RetroButton(
                  label: 'HARD',
                  fontSize: 9,
                  isSelected: state.difficulty == AIDifficulty.hard,
                  color: state.difficulty == AIDifficulty.hard
                      ? const Color(0xFF4D1420)
                      : palette.surface,
                  borderColor: state.difficulty == AIDifficulty.hard
                      ? const Color(0xFFFF2A55)
                      : Colors.white12,
                  textColor: state.difficulty == AIDifficulty.hard
                      ? const Color(0xFFFF2A55)
                      : Colors.white60,
                  onPressed: () => onDifficultyChanged(AIDifficulty.hard),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final GameState state;
  final RetroThemePalette palette;

  const _StatusBanner({
    required this.state,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;

    if (state.status == GameStatus.won) {
      if (state.gameMode == GameMode.ai) {
        if (state.winner == BoardLogic.player1) {
          message = '★ YOU WIN! ★';
          color = palette.winGlow;
        } else {
          message = 'AI VICTORIOUS!';
          color = palette.player2;
        }
      } else {
        message = state.winner == BoardLogic.player1
            ? '★ PLAYER 1 WINS! ★'
            : '★ PLAYER 2 WINS! ★';
        color = state.winner == BoardLogic.player1
            ? palette.player1
            : palette.player2;
      }
    } else if (state.status == GameStatus.draw) {
      message = '= GAME DRAW =';
      color = Colors.white70;
    } else if (state.isAiThinking) {
      message = 'AI IS THINKING...';
      color = palette.player2;
    } else {
      if (state.gameMode == GameMode.ai) {
        message = 'YOUR TURN';
        color = palette.player1;
      } else {
        message = state.isPlayer1Turn ? "PLAYER 1'S TURN" : "PLAYER 2'S TURN";
        color = state.isPlayer1Turn ? palette.player1 : palette.player2;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: RetroTypography.pixel(
            fontSize: 12,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ErrorMessageView extends StatelessWidget {
  final String message;

  const _ErrorMessageView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF280A10),
        border: Border.all(color: Colors.redAccent, width: 1.5),
      ),
      child: SelectableText.rich(
        TextSpan(
          text: '! $message',
          style: RetroTypography.pixel(
            fontSize: 9,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}

class _GameControls extends StatelessWidget {
  final GameState state;
  final RetroThemePalette palette;
  final VoidCallback onRestart;
  final VoidCallback onUndo;

  const _GameControls({
    required this.state,
    required this.palette,
    required this.onRestart,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RetroButton(
            label: 'UNDO',
            icon: Icons.undo,
            color: palette.surface,
            borderColor: Colors.white24,
            onPressed: state.canUndo ? onUndo : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RetroButton(
            label: 'RESTART',
            icon: Icons.refresh,
            color: palette.surface,
            borderColor: palette.accent,
            textColor: palette.accent,
            onPressed: onRestart,
          ),
        ),
      ],
    );
  }
}
