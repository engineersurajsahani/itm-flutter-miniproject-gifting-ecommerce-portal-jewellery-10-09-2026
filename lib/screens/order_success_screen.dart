import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import '../models/order.dart';
import '../widgets/luxury_divider.dart';
import '../widgets/luxury_button.dart';
import 'main_root_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  late Animation<double> _sparkAnimation;

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _sparkAnimation = CurvedAnimation(
      parent: _sparkController,
      curve: Curves.elasticOut,
    );
    _sparkController.forward();
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.forestGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated glowing crest
                  ScaleTransition(
                    scale: _sparkAnimation,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LuxuryTheme.gold.withValues(alpha: 0.12),
                        border: Border.all(color: LuxuryTheme.gold, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.verified_rounded,
                        color: LuxuryTheme.gold,
                        size: 44,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  Text(
                    "CONGRATULATIONS",
                    style: LuxuryTheme.displayBrand(size: 24, color: LuxuryTheme.gold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "RESERVATION VAULT SECURED",
                    style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.cream.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const LuxuryDivider(width: 80),
                  const SizedBox(height: 24),
                  
                  Text(
                    "Your precious metals are reserved in vault storage. Master bench craftsmen have been assigned to prepare your gifting selections.",
                    style: LuxuryTheme.bodySerif(size: 16, color: LuxuryTheme.cream.withValues(alpha: 0.95)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Elegant Pergament Receipt of Reservation Details
                  Container(
                    decoration: BoxDecoration(
                      color: LuxuryTheme.cream,
                      border: Border.all(color: LuxuryTheme.warmSand, width: 2),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ORDER TRANSACTION ID",
                              style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.forestGreen),
                            ),
                            Text(
                              widget.order.id,
                              style: LuxuryTheme.bodySans(size: 12, bold: true, color: LuxuryTheme.forestGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SECURED VAULT LOCK CODE",
                              style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.forestGreen),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              color: LuxuryTheme.gold.withValues(alpha: 0.2),
                              child: Text(
                                widget.order.secureVaultCode,
                                style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.forestGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: LuxuryTheme.warmSand, thickness: 1),
                        const SizedBox(height: 16),
                        
                        Text(
                          "VAULT ACQUISITIONS",
                          style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.grayMuted),
                        ),
                        const SizedBox(height: 8),

                        ...widget.order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item.productName} (x${item.quantity})",
                                    style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "₹${item.total.toStringAsFixed(0)}",
                                  style: LuxuryTheme.bodySans(size: 13, bold: true),
                                )
                              ],
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 12),
                        Divider(color: LuxuryTheme.warmSand),
                        const SizedBox(height: 12),
                        
                        _receiptRow("Fine metals aggregate", "₹${widget.order.subtotal.toStringAsFixed(2)}"),
                        if (widget.order.giftCustomizationTotal > 0.0)
                          _receiptRow("Personalization premium wrapping", "₹${widget.order.giftCustomizationTotal.toStringAsFixed(2)}"),
                        _receiptRow("Armored Secure Dispatch", "COMPLIMENTARY", valueColor: LuxuryTheme.emerald, isBold: true),
                        _receiptRow("State Duty (8%)", "₹${widget.order.tax.toStringAsFixed(2)}"),
                        
                        const SizedBox(height: 10),
                        Divider(color: LuxuryTheme.warmSand, thickness: 1),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SECURED VALUE ESCROWED:",
                              style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.forestGreen),
                            ),
                            Text(
                              "₹${widget.order.grandTotal.toStringAsFixed(2)}",
                              style: LuxuryTheme.displayBrand(size: 15, color: LuxuryTheme.emerald),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  LuxuryButton(
                    text: "Track artisanal progress",
                    onPressed: () {
                      // Navigate back to main screen, landing on the Profile tab
                      // (index 2) so the new order is right there.
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainRootScreen(initialIndex: 2),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainRootScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "RETURN TO THE ATELIER",
                      style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: LuxuryTheme.bodySerif(size: 13, color: LuxuryTheme.grayMuted, bold: true),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(value, style: LuxuryTheme.bodySans(size: 12, color: valueColor ?? LuxuryTheme.blackJet, bold: isBold)),
        ],
      ),
    );
  }
}
