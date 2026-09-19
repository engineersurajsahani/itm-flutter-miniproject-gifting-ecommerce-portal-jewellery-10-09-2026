import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class LuxuryDivider extends StatelessWidget {
  final double width;
  final Color color;

  const LuxuryDivider({
    super.key,
    this.width = 100.0,
    this.color = LuxuryTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.01), color, color.withValues(alpha: 0.5)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: LuxuryTheme.forestGreen, width: 0.5),
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.5), color, color.withValues(alpha: 0.01)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
