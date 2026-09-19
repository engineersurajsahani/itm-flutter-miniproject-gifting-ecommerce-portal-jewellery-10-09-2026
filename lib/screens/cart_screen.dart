import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../models/cart.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/luxury_divider.dart';
import '../widgets/luxury_button.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final cartItems = provider.cartItems;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "YOUR JEWELLERY CHEST",
          style: LuxuryTheme.displayBrand(size: 14, color: LuxuryTheme.creamText),
        ),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyChest(context)
            : isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop Left Column: List of items
                      Expanded(
                        flex: 7,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(32),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartItemCard(context, cartItems[index], provider);
                          },
                        ),
                      ),
                      
                      // Desktop Right Column: Fixed invoice total calculation and proceed
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 32, right: 32, bottom: 120),
                          child: _buildSummaryInvoice(context, provider),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              return _buildCartItemCard(context, cartItems[index], provider);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryInvoice(context, provider),
                          const SizedBox(height: 110), // Padding to avoid floated mobile navigation bar
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyChest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: LuxuryTheme.gold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Your Chest is Empty",
              style: LuxuryTheme.headlineElegant(size: 22, color: LuxuryTheme.forestGreen),
            ),
            const SizedBox(height: 8),
            Text(
              "Meticulous, handmolded rings and gemstone wonders await your gaze in our grand catalogue.",
              style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const LuxuryDivider(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, ShopProvider provider) {
    final subtotal = item.product.price * item.quantity;
    final total = item.itemTotal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand.withValues(alpha: 0.8), width: 1.5),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 6),
      ),
      child: Column(
        children: [
          // Row of image and description details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small thumb
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: LuxuryTheme.forestGreen,
                    border: Border.all(color: LuxuryTheme.warmSand, width: 1),
                  ),
                  child: Image.network(
                    item.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.collection.toUpperCase(),
                        style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.product.name,
                        style: LuxuryTheme.headlineElegant(size: 16, color: LuxuryTheme.forestGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.product.gemstone} • ${item.product.metalType}",
                        style: LuxuryTheme.bodySerif(size: 12, color: LuxuryTheme.grayMuted, bold: true),
                      ),
                      const SizedBox(height: 8),
                      // Core Product cost
                      Text(
                        "₹${item.product.price.toStringAsFixed(0)} each",
                        style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.blackJet),
                      ),
                    ],
                  ),
                ),

                // Absolute Price Tag and Remove Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: LuxuryTheme.grayMuted),
                      onPressed: () {
                        provider.removeFromCart(item);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "₹${subtotal.toStringAsFixed(0)}",
                      style: LuxuryTheme.displayBrand(size: 14, color: LuxuryTheme.forestGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Render optional customized gifting details in an elegant nested layout
          if (item.giftPackaging != GiftPackaging.none || item.engravingText != null || item.customGreetingMessage != null || item.wrapInGoldFoil) ...[
            Container(
              decoration: BoxDecoration(
                color: LuxuryTheme.creamText.withValues(alpha: 0.4),
                border: Border(
                  top: BorderSide(color: LuxuryTheme.creamText, width: 1.5),
                  bottom: BorderSide(color: LuxuryTheme.creamText, width: 1.5),
                ),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded, color: LuxuryTheme.gold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "GIFT CUSTOMIZATIONS PREVIEW",
                        style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Selected Box
                  if (item.giftPackaging != GiftPackaging.none)
                    _buildGiftingDetailItem(
                      "Presentation Box:", 
                      "${item.packagingName} (+₹${item.packagingPrice.toStringAsFixed(0)})"
                    ),

                  // Engraving Selection
                  if (item.engravingText != null)
                    _buildGiftingDetailItem(
                      "Laser Engraving:", 
                      "\"${item.engravingText}\" (Complementary)"
                    ),

                  // Sealed Greetings Selection
                  if (item.customGreetingMessage != null)
                    _buildGiftingDetailItem(
                      "Wax-Sealed Greetings:", 
                      "\"${item.customGreetingMessage}\" (Scribed in Calligraphy)"
                    ),

                  // Gold foil selection
                  if (item.wrapInGoldFoil)
                    _buildGiftingDetailItem(
                      "Foil & Silk Packaging:", 
                      "Yes, wrapped in premium gold leaf foil and emerald ribbon (+₹5.00)"
                    ),
                ],
              ),
            ),
          ],

          // Footer containing item quantities management and final sum
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _quantityControl(Icons.remove, () {
                      provider.updateCartItemQuantity(item, -1);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        item.quantity.toString(),
                        style: LuxuryTheme.displayBrand(size: 14, color: LuxuryTheme.forestGreen),
                      ),
                    ),
                    _quantityControl(Icons.add, () {
                      if (item.quantity < item.product.stock) {
                        provider.updateCartItemQuantity(item, 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("We are restricted by available handcrafted quantities currently in vault stock."),
                            backgroundColor: Color(0xFF8B1E2B),
                          ),
                        );
                      }
                    }),
                  ],
                ),
                
                // Composite total cost
                Text(
                  "Item Gross: ₹${total.toStringAsFixed(0)}",
                  style: LuxuryTheme.displayBrand(size: 12, color: LuxuryTheme.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftingDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: LuxuryTheme.bodySerif(size: 12, color: LuxuryTheme.forestGreen, bold: true),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.blackJet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityControl(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: LuxuryTheme.creamText,
          border: Border.all(color: LuxuryTheme.warmSand),
        ),
        child: Icon(icon, color: LuxuryTheme.forestGreen, size: 14),
      ),
    );
  }

  Widget _buildSummaryInvoice(BuildContext context, ShopProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 2),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 15),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "COMPLIMENTARY SERVICES",
            style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildPerkItem(Icons.security, "Fully Insured Armored Logistics Delivery"),
          _buildPerkItem(Icons.verified, "Certified Metal Purity & Gemstone Grading Certificate"),
          _buildPerkItem(Icons.refresh, "30-Day Complimentary Sovereign Trade-In Policy"),
          
          const SizedBox(height: 20),
          Divider(color: LuxuryTheme.creamText, thickness: 1),
          const SizedBox(height: 20),
          
          Text(
            "TOTAL VAULT SECURED VALUE",
            style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
          ),
          const SizedBox(height: 16),
          
          // Subtotal
          _buildReceiptRow("Fine Metal Subtotal", "₹${provider.cartSubtotal.toStringAsFixed(2)}"),
          
          // Gifting customization charge
          if (provider.cartGiftCustomizationTotal > 0.0)
            _buildReceiptRow("Premium Gift Preparation", "+₹${provider.cartGiftCustomizationTotal.toStringAsFixed(2)}"),

          // Armored logistics charge
          _buildReceiptRow("Armored Secure Courier", "COMPLIMENTARY", valueColor: LuxuryTheme.emerald, isBold: true),

          // Security tax
          _buildReceiptRow("Luxury Jewellry State Tax (8%)", "₹${provider.cartTax.toStringAsFixed(2)}"),

          const SizedBox(height: 12),
          Divider(color: LuxuryTheme.creamText, thickness: 1),
          const SizedBox(height: 12),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sovereign Total:",
                style: LuxuryTheme.displayBrand(size: 12, color: LuxuryTheme.forestGreen),
              ),
              Text(
                "₹${provider.cartGrandTotal.toStringAsFixed(2)}",
                style: LuxuryTheme.displayBrand(size: 18, color: LuxuryTheme.emerald),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          LuxuryButton(
            text: "Proceed to Checkout Portal",
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              if (!auth.isLoggedIn) {
                final signedIn = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (signedIn != true || !context.mounted || !auth.isLoggedIn) return;
              }
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CheckoutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: LuxuryTheme.gold, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: LuxuryTheme.bodySerif(size: 13, color: LuxuryTheme.forestGreen, bold: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.grayMuted, bold: true),
          ),
          Text(
            value,
            style: LuxuryTheme.bodySans(
              size: 13, 
              color: valueColor ?? LuxuryTheme.blackJet,
              bold: isBold,
            ),
          ),
        ],
      ),
    );
  }
}
