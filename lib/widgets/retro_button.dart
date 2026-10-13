import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool isSelected;
  final bool isCompact;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.borderColor,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.isSelected = false,
    this.isCompact = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final baseColor = widget.color ?? const Color(0xFF1B244A);
    final borderColor = widget.borderColor ??
        (widget.isSelected ? const Color(0xFF00E5FF) : Colors.white24);
    final textColor = widget.textColor ??
        (isEnabled ? Colors.white : Colors.white38);

    final displayColor = !isEnabled
        ? baseColor.withValues(alpha: 0.3)
        : _isPressed
            ? baseColor.withValues(alpha: 0.7)
            : _isHovered
                ? Color.lerp(baseColor, Colors.white, 0.15)!
                : baseColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 2 : 0,
            0,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: displayColor,
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 2.5 : 2.0,
            ),
            boxShadow: [
              if (widget.isSelected || _isHovered)
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: Offset(0, _isPressed ? 1 : 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: _ButtonContent(
            label: widget.label,
            icon: widget.icon,
            fontSize: widget.fontSize,
            textColor: textColor,
            isCompact: widget.isCompact,
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double fontSize;
  final Color textColor;
  final bool isCompact;

  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.fontSize,
    required this.textColor,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(
        label,
        textAlign: TextAlign.center,
        style: RetroTypography.pixel(
          fontSize: fontSize,
          color: textColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: fontSize + 4, color: textColor),
        if (!isCompact) SizedBox(width: fontSize * 0.7),
        if (!isCompact)
          Text(
            label,
            textAlign: TextAlign.center,
            style: RetroTypography.pixel(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
      ],
    );
  }
}
