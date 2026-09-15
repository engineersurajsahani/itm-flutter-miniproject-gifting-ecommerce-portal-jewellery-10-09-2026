import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../services/api_service.dart';
import '../widgets/luxury_button.dart';
import '../widgets/luxury_divider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping details — name/card owner default to the signed-in consumer;
  // everything else starts blank rather than a fictional pre-filled person.
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  // Payment details
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final consumer = context.read<AuthProvider>().currentConsumer;
    if (consumer != null) {
      _nameController.text = consumer.fullName;
      _cardNameController.text = consumer.fullName.toUpperCase();
    }
  }

  // Loading States for custom checkout authorization animation
  bool _isProcessingTransaction = false;
  int _verificationStage = 0;
  final List<String> _verificationStages = [
    "Establishing end-to-end Bank Vault Handshake...",
    "Securing Escrow Liquidity Reservation...",
    "Validating Fine Metal Weight Allocations in physical vaults...",
    "Generating Authentic Holographic Certificate...",
    "Transaction Formally Authenticated & Secured!",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  String _paymentMethodLabel() {
    final digits = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return "Credit Card";
    return "Credit Card •••• ${digits.substring(digits.length - 4)}";
  }

  void _runInteractiveCheckoutSimulation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessingTransaction = true;
      _verificationStage = 0;
    });

    _animateStages();
  }

  void _animateStages() {
    if (_verificationStage < _verificationStages.length - 1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _verificationStage++;
          });
          _animateStages();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1100), () async {
        if (!mounted) return;

        try {
          final order = await context.read<ShopProvider>().submitOrder(
                fullName: _nameController.text,
                addressLine1: _addressController.text,
                city: _cityController.text,
                postalCode: _zipController.text,
                phone: _phoneController.text,
                paymentMethod: _paymentMethodLabel(),
              );

          if (!mounted) return;
          setState(() {
            _isProcessingTransaction = false;
          });

          // Redirect to the success screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(order: order),
            ),
            (route) => route.isFirst, // Back to splash/root home screen
          );
        } on ApiException catch (e) {
          if (!mounted) return;
          setState(() {
            _isProcessingTransaction = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: const Color(0xFF8B1E2B)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SECURE CHECKOUT TERMINAL",
          style: LuxuryTheme.displayBrand(size: 13, color: LuxuryTheme.cream),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 40 : 20),
              child: Form(
                key: _formKey,
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side Form
                          Expanded(
                            flex: 7,
                            child: _buildInputFields(),
                          ),
                          const SizedBox(width: 40),
                          
                          // Right side summary of items and totals
                          Expanded(
                            flex: 5,
                            child: _buildRightDesktopSidebar(provider),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputFields(),
                          const SizedBox(height: 24),
                          _buildMobileQuickTotals(provider),
                          const SizedBox(height: 120), // Floated nav space padding
                        ],
                      ),
              ),
            ),
          ),

          // Custom Bank-Grade Payment Authorization Overlay Modal
          if (_isProcessingTransaction)
            _buildSimulationProgressOverlay(),
        ],
      ),
    );
  }

  Widget _buildRightDesktopSidebar(ShopProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPaymentSummaryCard(provider),
        const SizedBox(height: 24),
        _buildCreditCardAesthetics(),
      ],
    );
  }

  Widget _buildMobileQuickTotals(ShopProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCreditCardAesthetics(),
        const SizedBox(height: 20),
        _buildPaymentSummaryCard(provider),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Delivery Details
        Row(
          children: [
            const Icon(Icons.room_outlined, color: LuxuryTheme.gold),
            const SizedBox(width: 10),
            Text(
              "I. COURIER DESTINATION DETAILED RECORD",
              style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildTextBox(_nameController, "FullName / Title of Addressee", Icons.person_outline),
        _buildTextBox(_addressController, "Street Address of Recipient", Icons.home_outlined),
        
        Row(
          children: [
            Expanded(
              child: _buildTextBox(_cityController, "City / Territory", Icons.location_city_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextBox(_zipController, "Postal Code / Zip", Icons.mark_as_unread_outlined),
            ),
          ],
        ),
        _buildTextBox(_phoneController, "Contact secure phone number", Icons.phone_android_outlined),
        
        const SizedBox(height: 32),
        const LuxuryDivider(width: 120),
        const SizedBox(height: 32),

        // 2. Secured Payment Details
        Row(
          children: [
            const Icon(Icons.payment_rounded, color: LuxuryTheme.gold),
            const SizedBox(width: 10),
            Text(
              "II. SECURE METALS INTEGRATION (CREDIT CARD CARD)",
              style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextBox(_cardNameController, "Card Owner Name (As Printed)", Icons.badge_outlined),
        _buildTextBox(_cardNumberController, "Sovereign card number", Icons.credit_card),
        
        Row(
          children: [
            Expanded(
              child: _buildTextBox(_cardExpiryController, "Expiry Dates (MM/YY)", Icons.date_range_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextBox(_cardCvvController, "CVV security", Icons.security),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextBox(TextEditingController controller, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.forestGreen, bold: true),
        cursorColor: LuxuryTheme.forestGreen,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required.";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.grayMuted),
          prefixIcon: Icon(icon, color: LuxuryTheme.gold),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ShopProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "RESERVED VAULT RECEIPT",
            style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...provider.cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${item.product.name} (x${item.quantity})",
                      style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹${(item.product.price * item.quantity).toStringAsFixed(0)}",
                    style: LuxuryTheme.bodySans(size: 13, bold: true),
                  )
                ],
              ),
            );
          }),
          
          const SizedBox(height: 16),
          Divider(color: LuxuryTheme.cream),
          const SizedBox(height: 12),

          _receiptInvoiceRow("Subtotal Weight Value", "₹${provider.cartSubtotal.toStringAsFixed(2)}"),
          if (provider.cartGiftCustomizationTotal > 0.0)
            _receiptInvoiceRow("Prestige Gifting Wrapping", "₹${provider.cartGiftCustomizationTotal.toStringAsFixed(2)}"),
          _receiptInvoiceRow("Insured Delivery Shipping", "COMPLIMENTARY", valueColor: LuxuryTheme.emerald, isBold: true),
          _receiptInvoiceRow("Luxury Government Duty Tax (8%)", "₹${provider.cartTax.toStringAsFixed(2)}"),
          
          const SizedBox(height: 12),
          Divider(color: LuxuryTheme.cream, thickness: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Escrow Charge:",
                style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
              ),
              Text(
                "₹${provider.cartGrandTotal.toStringAsFixed(2)}",
                style: LuxuryTheme.displayBrand(size: 16, color: LuxuryTheme.emerald),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          LuxuryButton(
            text: "Authorize Sovereign Transaction",
            onPressed: () {
              _runInteractiveCheckoutSimulation();
            },
          ),
        ],
      ),
    );
  }

  Widget _receiptInvoiceRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.grayMuted, bold: true)),
          Text(value, style: LuxuryTheme.bodySans(size: 13, color: valueColor ?? LuxuryTheme.blackJet, bold: isBold)),
        ],
      ),
    );
  }

  Widget _buildCreditCardAesthetics() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LuxuryTheme.goldGradient,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Color(0x3B6B5C28),
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AURELIA SECURED",
                style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
              ),
              const Icon(
                Icons.wifi_lock_rounded,
                color: LuxuryTheme.forestGreen,
                size: 20,
              ),
            ],
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _cardNumberController.text.isEmpty ? "•••• •••• •••• ••••" : _cardNumberController.text,
                style: LuxuryTheme.displayBrand(size: 16, color: LuxuryTheme.forestGreen),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _cardNameController.text.isEmpty ? "SOVEREIGN MEMBER" : _cardNameController.text.toUpperCase(),
                    style: LuxuryTheme.bodySans(size: 12, bold: true, color: LuxuryTheme.forestGreen),
                  ),
                  Text(
                    _cardExpiryController.text.isEmpty ? "MM/YY" : _cardExpiryController.text,
                    style: LuxuryTheme.bodySans(size: 12, bold: true, color: LuxuryTheme.forestGreen),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSimulationProgressOverlay() {
    final curStep = _verificationStages[_verificationStage];
    final prog = (_verificationStage + 1) / _verificationStages.length;

    return Positioned.fill(
      child: Container(
        color: LuxuryTheme.forestGreen.withValues(alpha: 0.97),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Royal Crown loading ring
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: prog,
                          color: LuxuryTheme.gold,
                          backgroundColor: LuxuryTheme.cream.withValues(alpha: 0.12),
                          strokeWidth: 2,
                        ),
                      ),
                      const Icon(
                        Icons.fingerprint_rounded,
                        color: LuxuryTheme.gold,
                        size: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                
                Text(
                  "VAULT ESCROW IN PROGRESS",
                  style: LuxuryTheme.displayBrand(size: 15, color: LuxuryTheme.gold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  "BANK DECENTRALIZED CLEARING",
                  style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.cream.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const LuxuryDivider(width: 80),
                const SizedBox(height: 24),

                // Active step statement with slight subtle layout changes
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    curStep,
                    key: ValueKey<int>(_verificationStage),
                    style: LuxuryTheme.bodySerif(
                      size: 18, 
                      color: LuxuryTheme.cream.withValues(alpha: 0.95),
                      bold: true,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Loading percent
                Text(
                  "${(prog * 100).toInt()}% Secure",
                  style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
