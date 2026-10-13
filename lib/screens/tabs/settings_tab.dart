import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/settings_cubit.dart';
import '../../theme/retro_theme.dart';
import '../../widgets/retro_button.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final settings = context.watch<SettingsCubit>().state;
    final palette = settings.palette;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          _HeaderCard(palette: palette),
          const SizedBox(height: 16),

          // Theme Selector Section
          _SectionTitle(title: 'COLOR PALETTE', palette: palette),
          const SizedBox(height: 8),

          _ThemeOptionCard(
            title: 'CLASSIC ARCADE',
            subtitle: 'Deep Navy / Neon Red / Gold',
            isSelected: settings.paletteType == RetroPaletteType.arcade,
            previewColors: const [
              Color(0xFF1044A5),
              Color(0xFFFF2A55),
              Color(0xFFFFD214),
            ],
            palette: palette,
            onTap: () => settingsCubit.setPaletteType(RetroPaletteType.arcade),
          ),
          const SizedBox(height: 10),

          _ThemeOptionCard(
            title: 'CYBERPUNK NEON',
            subtitle: 'Synthwave Purple / Hot Pink / Cyan',
            isSelected: settings.paletteType == RetroPaletteType.cyberpunk,
            previewColors: const [
              Color(0xFF541388),
              Color(0xFFFF007F),
              Color(0xFF00F0FF),
            ],
            palette: palette,
            onTap: () => settingsCubit.setPaletteType(RetroPaletteType.cyberpunk),
          ),
          const SizedBox(height: 10),

          _ThemeOptionCard(
            title: 'GAME BOY 8-BIT',
            subtitle: 'Monochrome Olive Green Nostalgia',
            isSelected: settings.paletteType == RetroPaletteType.gameboy,
            previewColors: const [
              Color(0xFF0F380F),
              Color(0xFF306230),
              Color(0xFF9BBC0F),
            ],
            palette: palette,
            onTap: () => settingsCubit.setPaletteType(RetroPaletteType.gameboy),
          ),
          const SizedBox(height: 20),

          // Audio & Visual Effects Section
          _SectionTitle(title: 'DISPLAY & AUDIO', palette: palette),
          const SizedBox(height: 8),

          _ToggleCard(
            title: 'SOUND EFFECTS',
            subtitle: '8-bit audio feedback',
            icon: settings.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
            value: settings.isSoundEnabled,
            palette: palette,
            onToggle: settingsCubit.toggleSound,
          ),
          const SizedBox(height: 10),

          _ToggleCard(
            title: 'CRT SCANLINES',
            subtitle: 'Retro cathode-ray tube screen overlay',
            icon: Icons.tv,
            value: settings.isCrtScanlinesEnabled,
            palette: palette,
            onToggle: settingsCubit.toggleCrtScanlines,
          ),
          const SizedBox(height: 20),

          // How to play & Credits
          _SectionTitle(title: 'ABOUT & RULES', palette: palette),
          const SizedBox(height: 8),

          _InfoCard(palette: palette),
          const SizedBox(height: 24),
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
          Icon(Icons.tune, size: 36, color: palette.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM CONFIG',
                  style: RetroTypography.pixel(
                    fontSize: 14,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CUSTOMIZE VISUALS & RETRO SFX',
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

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final List<Color> previewColors;
  final RetroThemePalette palette;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.previewColors,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? palette.border : Colors.white12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceLight : palette.surface,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: palette.border.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? palette.accent : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RetroTypography.pixel(
                      fontSize: 10,
                      color: isSelected ? palette.accent : palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: RetroTypography.pixel(
                      fontSize: 8,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: previewColors
                  .map(
                    (color) => Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.white60, width: 1),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final RetroThemePalette palette;
  final VoidCallback onToggle;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.palette,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(
          color: value ? palette.accent.withValues(alpha: 0.7) : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? palette.accent : Colors.white38,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RetroTypography.pixel(
                    fontSize: 10,
                    color: value ? palette.accent : palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: RetroTypography.pixel(
                    fontSize: 8,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          RetroButton(
            label: value ? 'ON' : 'OFF',
            fontSize: 9,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            isSelected: value,
            color: value ? palette.surfaceLight : Colors.black45,
            borderColor: value ? palette.winGlow : Colors.white24,
            textColor: value ? palette.winGlow : Colors.white38,
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final RetroThemePalette palette;

  const _InfoCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO PLAY:',
            style: RetroTypography.pixel(
              fontSize: 10,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Drop coins into any column. Connect 4 coins in a line horizontally, vertically, or diagonally to win before your opponent!',
            style: RetroTypography.pixel(
              fontSize: 8,
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI ENGINE:',
            style: RetroTypography.pixel(
              fontSize: 10,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hard mode runs Alpha-Beta Minimax tree search with 4-in-a-row pattern heuristic weighting.',
            style: RetroTypography.pixel(
              fontSize: 8,
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
