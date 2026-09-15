import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _fadeController.forward().then((_) {
      // Small pause of 1 second before navigating
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const AuthGate(),
              transitionsBuilder: (_, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LuxuryTheme.emeraldGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background branding pattern (geometric lines)
            Positioned.fill(
              child: Opacity(
                opacity: 0.02,
                child: CustomPaint(
                  painter: GridPatternPainter(),
                ),
              ),
            ),
            
            // Fading brand logo group
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Majestic Golden Emblem
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.8), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.3), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.diamond_outlined,
                            size: 32,
                            color: LuxuryTheme.gold,
                          ),
                          SizedBox(height: 2),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: LuxuryTheme.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Majestic Brand Header
                  Text(
                    "AURELIA",
                    style: LuxuryTheme.displayBrand(size: 38, color: LuxuryTheme.gold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sovereign Subtitle
                  Text(
                    "MAISON DE HAUTE JOAILLERIE",
                    style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.gold.withValues(alpha: 0.7)),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Decorative Small Diamond Divider
                  const SizedBox(
                    width: 140,
                    child: Divider(
                      color: LuxuryTheme.gold,
                      thickness: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Cinematic Slogan
                  Text(
                    "CRAFTED FOR ETERNITY",
                    style: LuxuryTheme.bodySerif(
                      size: 14,
                      color: LuxuryTheme.cream.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal painter to simulate a luxury watermark backdrop pattern
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LuxuryTheme.gold
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
