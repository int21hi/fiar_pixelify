import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/settings_cubit.dart';
import '../theme/retro_theme.dart';
import 'tabs/game_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/stats_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 1; // Default to Tab 1 (Center): Main Game

  final List<Widget> _tabs = const [
    StatsTab(),
    GameTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final palette = settings.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: _RetroAppBar(palette: palette),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: _tabs,
          ),
          if (settings.isCrtScanlinesEnabled)
            const Positioned.fill(
              child: IgnorePointer(
                child: _CrtScanlinesOverlay(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _RetroBottomNavBar(
        currentIndex: _currentTabIndex,
        palette: palette,
        onTap: (index) => setState(() => _currentTabIndex = index),
      ),
    );
  }
}

class _RetroAppBar extends StatelessWidget {
  final RetroThemePalette palette;

  const _RetroAppBar({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.border, width: 2.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: palette.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FOUR IN A ROW',
                    style: RetroTypography.pixel(
                      fontSize: 12,
                      color: palette.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(color: palette.border, width: 1),
                ),
                child: Text(
                  '8-BIT',
                  style: RetroTypography.pixel(
                    fontSize: 8,
                    color: palette.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final RetroThemePalette palette;
  final ValueChanged<int> onTap;

  const _RetroBottomNavBar({
    required this.currentIndex,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          top: BorderSide(color: palette.border, width: 2.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _NavBarItem(
                label: 'STATS',
                icon: Icons.bar_chart,
                isSelected: currentIndex == 0,
                palette: palette,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                label: 'GAME',
                icon: Icons.grid_view_sharp,
                isSelected: currentIndex == 1,
                palette: palette,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                label: 'CONFIG',
                icon: Icons.settings,
                isSelected: currentIndex == 2,
                palette: palette,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final RetroThemePalette palette;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = palette.accent;
    final inactiveColor = palette.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? palette.surfaceLight : Colors.transparent,
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: activeColor, width: 3),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: RetroTypography.pixel(
                  fontSize: 8,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrtScanlinesOverlay extends StatelessWidget {
  const _CrtScanlinesOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanlinesPainter(),
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
