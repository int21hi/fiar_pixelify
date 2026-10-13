import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/settings_cubit.dart';
import '../../game/stats_cubit.dart';
import '../../theme/retro_theme.dart';
import '../../widgets/retro_button.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final palette = settings.palette;
    final stats = context.watch<StatsCubit>().state;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          _HeaderCard(palette: palette),
          const SizedBox(height: 16),

          // Overview metrics cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'TOTAL GAMES',
                  value: '${stats.totalGamesPlayed}',
                  color: palette.accent,
                  palette: palette,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'VS AI WIN %',
                  value: '${stats.overallWinRate.toStringAsFixed(1)}%',
                  color: palette.winGlow,
                  palette: palette,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AI Breakdown
          _SectionTitle(title: 'AI MATCHUPS', palette: palette),
          const SizedBox(height: 8),

          _DifficultyStatCard(
            title: 'EASY MODE',
            tagColor: const Color(0xFF39FF14),
            wins: stats.aiEasyWins,
            losses: stats.aiEasyLosses,
            draws: stats.aiEasyDraws,
            winRate: stats.easyWinRate,
            palette: palette,
          ),
          const SizedBox(height: 10),

          _DifficultyStatCard(
            title: 'NORMAL MODE',
            tagColor: const Color(0xFFFFD214),
            wins: stats.aiNormalWins,
            losses: stats.aiNormalLosses,
            draws: stats.aiNormalDraws,
            winRate: stats.normalWinRate,
            palette: palette,
          ),
          const SizedBox(height: 10),

          _DifficultyStatCard(
            title: 'HARD (MINIMAX)',
            tagColor: const Color(0xFFFF2A55),
            wins: stats.aiHardWins,
            losses: stats.aiHardLosses,
            draws: stats.aiHardDraws,
            winRate: stats.hardWinRate,
            palette: palette,
          ),
          const SizedBox(height: 16),

          // Local 2-Player breakdown
          _SectionTitle(title: 'PASS & PLAY (LOCAL)', palette: palette),
          const SizedBox(height: 8),

          _PvpStatCard(
            p1Wins: stats.pvpPlayer1Wins,
            p2Wins: stats.pvpPlayer2Wins,
            draws: stats.pvpDraws,
            palette: palette,
          ),
          const SizedBox(height: 24),

          // Reset Stats Action
          Center(
            child: RetroButton(
              label: 'RESET STATS',
              icon: Icons.delete_forever,
              color: const Color(0xFF360C14),
              borderColor: const Color(0xFFFF2A55),
              textColor: const Color(0xFFFF2A55),
              onPressed: () => _confirmReset(context, palette),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, RetroThemePalette palette) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF2A55), width: 2),
        ),
        title: Text(
          'RESET ALL STATS?',
          style: RetroTypography.pixel(
            fontSize: 12,
            color: const Color(0xFFFF2A55),
          ),
        ),
        content: Text(
          'This will permanently reset all game records and win rates.',
          style: RetroTypography.pixel(
            fontSize: 9,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: RetroTypography.pixel(fontSize: 10, color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<StatsCubit>().resetStats();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'RESET',
              style: RetroTypography.pixel(
                fontSize: 10,
                color: const Color(0xFFFF2A55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final RetroThemePalette palette;

  const _HeaderCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, size: 36, color: palette.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HALL OF FAME',
                  style: RetroTypography.pixel(
                    fontSize: 14,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PLAYER PROFILE & LIFETIME STATS',
                  style: RetroTypography.pixel(
                    fontSize: 8,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final RetroThemePalette palette;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: RetroTypography.pixel(
              fontSize: 8,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: RetroTypography.readout(
              fontSize: 26,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final RetroThemePalette palette;

  const _SectionTitle({required this.title, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      '// $title',
      style: RetroTypography.pixel(
        fontSize: 10,
        color: palette.accent,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DifficultyStatCard extends StatelessWidget {
  final String title;
  final Color tagColor;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final RetroThemePalette palette;

  const _DifficultyStatCard({
    required this.title,
    required this.tagColor,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: tagColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: RetroTypography.pixel(
                  fontSize: 10,
                  color: tagColor,
                ),
              ),
              Text(
                '${winRate.toStringAsFixed(1)}% WR',
                style: RetroTypography.readout(
                  fontSize: 18,
                  color: tagColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(label: 'W', count: wins, color: palette.winGlow),
              const SizedBox(width: 8),
              _StatChip(label: 'L', count: losses, color: const Color(0xFFFF2A55)),
              const SizedBox(width: 8),
              _StatChip(label: 'D', count: draws, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }
}

class _PvpStatCard extends StatelessWidget {
  final int p1Wins;
  final int p2Wins;
  final int draws;
  final RetroThemePalette palette;

  const _PvpStatCard({
    required this.p1Wins,
    required this.p2Wins,
    required this.draws,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PvpCounter(
            title: 'PLAYER 1',
            wins: p1Wins,
            color: palette.player1,
          ),
          _PvpCounter(
            title: 'DRAWS',
            wins: draws,
            color: Colors.white60,
          ),
          _PvpCounter(
            title: 'PLAYER 2',
            wins: p2Wins,
            color: palette.player2,
          ),
        ],
      ),
    );
  }
}

class _PvpCounter extends StatelessWidget {
  final String title;
  final int wins;
  final Color color;

  const _PvpCounter({
    required this.title,
    required this.wins,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: RetroTypography.pixel(fontSize: 8, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          '$wins',
          style: RetroTypography.readout(fontSize: 24, color: color),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        '$label: $count',
        style: RetroTypography.pixel(
          fontSize: 8,
          color: color,
        ),
      ),
    );
  }
}
