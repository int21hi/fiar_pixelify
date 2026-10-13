import 'package:flutter/material.dart';
import '../game/board_logic.dart';
import '../theme/retro_theme.dart';

class PixelCoin extends StatefulWidget {
  final int value;
  final bool isWinningPiece;
  final RetroThemePalette palette;
  final double size;

  const PixelCoin({
    super.key,
    required this.value,
    required this.palette,
    this.isWinningPiece = false,
    this.size = 40.0,
  });

  @override
  State<PixelCoin> createState() => _PixelCoinState();
}

class _PixelCoinState extends State<PixelCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isWinningPiece) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PixelCoin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWinningPiece && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isWinningPiece && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value == BoardLogic.empty) {
      return _EmptySlot(size: widget.size, palette: widget.palette);
    }

    final isP1 = widget.value == BoardLogic.player1;
    final coinColor = isP1 ? widget.palette.player1 : widget.palette.player2;

    Widget coin = _FilledCoin(
      size: widget.size,
      color: coinColor,
      isWinning: widget.isWinningPiece,
      glowColor: widget.palette.winGlow,
      palette: widget.palette,
    );

    if (widget.isWinningPiece) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: coin,
      );
    }

    return coin;
  }
}

class _EmptySlot extends StatelessWidget {
  final double size;
  final RetroThemePalette palette;

  const _EmptySlot({required this.size, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.boardHole,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.6),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledCoin extends StatelessWidget {
  final double size;
  final Color color;
  final bool isWinning;
  final Color glowColor;
  final RetroThemePalette palette;

  const _FilledCoin({
    required this.size,
    required this.color,
    required this.isWinning,
    required this.glowColor,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isWinning ? glowColor : Colors.white.withValues(alpha: 0.7),
            width: isWinning ? 3.5 : 2.5,
          ),
          boxShadow: [
            if (isWinning)
              BoxShadow(
                color: glowColor.withValues(alpha: 0.8),
                blurRadius: 14,
                spreadRadius: 4,
              )
            else
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            const BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Retro 8-bit specular pixel highlight in top-left
            Positioned(
              top: size * 0.18,
              left: size * 0.22,
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Inner pixel rim
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWinning
                      ? glowColor.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.25),
                  width: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
