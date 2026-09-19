import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class LuxuryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final bool isGrad;

  const LuxuryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.isGrad = true,
  });

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.zero), // Classy square luxury packaging theme
            border: Border.all(
              color: widget.isSecondary ? LuxuryTheme.forestGreen : Colors.transparent,
              width: 1,
            ),
            gradient: widget.isSecondary
                ? null
                : (widget.isGrad ? LuxuryTheme.goldGradient : const LinearGradient(colors: [LuxuryTheme.emerald, LuxuryTheme.forestGreen])),
            color: widget.isSecondary ? Colors.transparent : null,
            boxShadow: widget.isSecondary ? null : LuxuryTheme.luxuryShadow(blur: 10, color: LuxuryTheme.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSecondary ? LuxuryTheme.forestGreen : LuxuryTheme.cream,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: LuxuryTheme.buttonText(
                  color: widget.isSecondary ? LuxuryTheme.forestGreen : LuxuryTheme.cream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
