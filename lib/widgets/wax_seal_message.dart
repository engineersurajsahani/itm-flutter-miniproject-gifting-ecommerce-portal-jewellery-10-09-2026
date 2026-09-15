import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

class WaxSealMessage extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hint;
  final ValueChanged<String>? onChanged;

  const WaxSealMessage({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    this.onChanged,
  });

  @override
  State<WaxSealMessage> createState() => _WaxSealMessageState();
}

class _WaxSealMessageState extends State<WaxSealMessage> with SingleTickerProviderStateMixin {
  bool _isSealed = false;
  late AnimationController _sealController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _sealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _sealController,
      curve: Curves.elasticOut,
    );
    _rotationAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _sealController.dispose();
    super.dispose();
  }

  void _toggleSeal() {
    setState(() {
      if (_isSealed) {
        _sealController.reverse();
        _isSealed = false;
      } else {
        _sealController.forward();
        _isSealed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.cream, // Elegant paper color
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of Parchment Letter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: LuxuryTheme.forestGreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
                ),
                Icon(
                  Icons.gesture_rounded,
                  color: LuxuryTheme.gold.withValues(alpha: 0.7),
                  size: 14,
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text Field for calligraphic message
                Opacity(
                  opacity: _isSealed ? 0.3 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isSealed,
                    child: TextField(
                      controller: widget.controller,
                      maxLines: 4,
                      onChanged: widget.onChanged,
                      cursorColor: LuxuryTheme.forestGreen,
                      style: LuxuryTheme.bodySerif(size: 18, color: LuxuryTheme.forestGreen, bold: true),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: LuxuryTheme.bodySerif(
                          size: 16,
                          color: LuxuryTheme.grayMuted.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Animated Burgundy Wax Seal stamp appearing!
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: GestureDetector(
                      onTap: _toggleSeal,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B1E2B), // Royal Rich Crimson/Burgundy Wax
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B1E2B).withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xffa1293a),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: LuxuryTheme.gold,
                              size: 26,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "SEALED",
                              style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.gold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Seal/Unseal action bar
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: LuxuryTheme.warmSand, width: 0.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSealed ? "Card Sealed in Gold Envelope" : "Write your message, then Seal",
                  style: LuxuryTheme.bodySans(
                    size: 12,
                    color: _isSealed ? LuxuryTheme.emerald : LuxuryTheme.grayMuted,
                    bold: _isSealed,
                  ),
                ),
                TextButton(
                  onPressed: widget.controller.text.isEmpty ? null : _toggleSeal,
                  style: TextButton.styleFrom(
                    foregroundColor: _isSealed ? LuxuryTheme.blackJet : const Color(0xFF8B1E2B),
                  ),
                  child: Text(
                    _isSealed ? "BREAK SEAL" : "PRESS SEAL",
                    style: LuxuryTheme.displayBrand(size: 10, color: widget.controller.text.isEmpty ? LuxuryTheme.grayMuted : (_isSealed ? LuxuryTheme.blackJet : const Color(0xFF8B1E2B))),
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
