import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../providers/shop_provider.dart';
import '../widgets/luxury_divider.dart';
import '../widgets/luxury_button.dart';
import '../widgets/wax_seal_message.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _itemQuantity = 1;

  // Custom Gifting States
  bool _enableGifting = false;
  GiftPackaging _selectedPackaging = GiftPackaging.standard;
  final TextEditingController _engravingController = TextEditingController();
  final TextEditingController _greetingController = TextEditingController();
  bool _wrapInGoldFoil = false;

  @override
  void dispose() {
    _engravingController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  double get _calculatedCustomizationTotal {
    if (!_enableGifting) return 0.0;
    
    double packagingCost = 0.0;
    switch (_selectedPackaging) {
      case GiftPackaging.none:
      case GiftPackaging.standard:
        packagingCost = 10.0;
        break;
      case GiftPackaging.celestialBox:
        packagingCost = 20.0;
        break;
      case GiftPackaging.velvetCase:
        packagingCost = 35.0;
        break;
    }

    double foilCost = _wrapInGoldFoil ? 5.0 : 0.0;
    return (packagingCost + foilCost) * _itemQuantity;
  }

  double get _calculatedGrandTotal {
    return (widget.product.price * _itemQuantity) + _calculatedCustomizationTotal;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;

    return Scaffold(
      backgroundColor: LuxuryTheme.cream,
      appBar: AppBar(
        title: Text(
          widget.product.name.toUpperCase(),
          style: LuxuryTheme.displayBrand(size: 13, color: LuxuryTheme.creamText),
        ),
        backgroundColor: LuxuryTheme.forestGreen,
        foregroundColor: LuxuryTheme.gold,
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Desktop Left Column: Large Hero Image and highlights
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: LuxuryTheme.forestGreen,
                        border: Border(right: BorderSide(color: LuxuryTheme.warmSand, width: 2)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: 'prod-image-${widget.product.id}',
                              child: Image.network(
                                widget.product.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                          Positioned(
                            bottom: 40,
                            left: 40,
                            right: 40,
                            child: Card(
                              color: LuxuryTheme.forestGreen.withValues(alpha: 0.92),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide(color: LuxuryTheme.gold, width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.collection.toUpperCase(),
                                      style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.product.name,
                                      style: LuxuryTheme.headlineElegant(size: 22, color: LuxuryTheme.creamText),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.product.description,
                                      style: LuxuryTheme.bodySerif(size: 16, color: LuxuryTheme.creamText.withValues(alpha: 0.8)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Desktop Right Column: Scrollable configurations & Buy
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40.0),
                      child: _buildDetailsSidebar(context),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Large visual Header for mobile
                    _buildMobileVisualHeader(),
                    
                    // Core detail container
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandAndTitle(),
                          const SizedBox(height: 16),
                          
                          // General spec cards
                          _buildSpecGrids(),
                          const SizedBox(height: 20),
                          
                          // Gifting Section
                          _buildPremiumGiftingSection(),
                          const SizedBox(height: 28),
                          
                          // Bottom checkout calculation and order
                          _buildActionSection(context),
                          const SizedBox(height: 48), // Blank space for float bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Desktop details setup
  Widget _buildDetailsSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBrandAndTitle(),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: LuxuryTheme.bodySerif(size: 17, color: LuxuryTheme.blackJet),
        ),
        const SizedBox(height: 24),
        _buildSpecGrids(),
        const SizedBox(height: 24),
        _buildPremiumGiftingSection(),
        const SizedBox(height: 24),
        _buildActionSection(context),
      ],
    );
  }

  Widget _buildMobileVisualHeader() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: LuxuryTheme.forestGreen,
        boxShadow: LuxuryTheme.luxuryShadow(blur: 15),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'prod-image-${widget.product.id}',
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient cover
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.product.collection.toUpperCase(),
              style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: LuxuryTheme.gold, size: 18),
                const SizedBox(width: 4),
                Text(
                  widget.product.rating.toStringAsFixed(1),
                  style: LuxuryTheme.bodySans(size: 13, color: LuxuryTheme.blackJet, bold: true),
                ),
                Text(
                  " (${widget.product.reviewsCount} reviews)",
                  style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.grayMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.name,
          style: LuxuryTheme.headlineElegant(size: 26, color: LuxuryTheme.forestGreen),
        ),
        const SizedBox(height: 8),
        Text(
          "₹${widget.product.price.toStringAsFixed(2)}",
          style: LuxuryTheme.displayBrand(size: 20, color: LuxuryTheme.emerald),
        ),
        const SizedBox(height: 12),
        const LuxuryDivider(width: 80),
      ],
    );
  }

  Widget _buildSpecGrids() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildSpecCard("Metal Purity", widget.product.metalType, Icons.shield_rounded),
        _buildSpecCard("Gemstone details", widget.product.gemstone, Icons.diamond),
        _buildSpecCard("Metal weight", "${widget.product.weight} grams", Icons.balance_rounded),
        _buildSpecCard("Authentic Origin", "Certified Natural", Icons.verified_user_rounded),
      ],
    );
  }

  Widget _buildSpecCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: LuxuryTheme.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.grayMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: LuxuryTheme.bodySerif(size: 13, color: LuxuryTheme.forestGreen, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGiftingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: LuxuryTheme.forestGreen,
            border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: LuxuryTheme.gold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "PREMIUM CUSTOM GIFTING",
                    style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
                  ),
                ],
              ),
              Switch(
                value: _enableGifting,
                onChanged: (val) {
                  setState(() => _enableGifting = val);
                },
                activeThumbColor: LuxuryTheme.gold,
                activeTrackColor: LuxuryTheme.emerald,
                inactiveThumbColor: LuxuryTheme.warmSand,
                inactiveTrackColor: LuxuryTheme.forestGreen.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        if (_enableGifting) ...[
          Container(
            decoration: BoxDecoration(
              color: LuxuryTheme.whitePremium,
              border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "1. CHOOSE PRESENTATION VAULT",
                  style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.forestGreen),
                ),
                const SizedBox(height: 12),
                _buildPackagingRadio(
                  GiftPackaging.standard,
                  "Signature Linen Envelope & Box",
                  "Elegant linen wrapping with an envelope containing card. Cardboard-certified.",
                  10.0,
                ),
                _buildPackagingRadio(
                  GiftPackaging.celestialBox,
                  "Emerald Cedarwood Box",
                  "Hand-sanded aromatic forest wood box with engraved golden filigree crests.",
                  20.0,
                ),
                _buildPackagingRadio(
                  GiftPackaging.velvetCase,
                  "Imperial Silk-Lined Velvet Vault",
                  "The ultimate offering. Thick emerald green jewel vault lined with gold-braided silk.",
                  35.0,
                ),
                
                const SizedBox(height: 20),
                Divider(color: LuxuryTheme.creamText, height: 1),
                const SizedBox(height: 20),
                
                // Engraving option
                Text(
                  "2. HAND-ENGRAVE BANNER (Inside band / edge)",
                  style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.forestGreen),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: LuxuryTheme.creamText,
                    border: Border.all(color: LuxuryTheme.warmSand),
                  ),
                  child: TextField(
                    controller: _engravingController,
                    maxLength: 24,
                    cursorColor: LuxuryTheme.forestGreen,
                    style: LuxuryTheme.bodySerif(size: 15, bold: true, color: LuxuryTheme.forestGreen),
                    decoration: const InputDecoration(
                      hintText: "E.g. \"A & E 2026\" (Complementary)",
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Wax Seal Message Card Option
                Text(
                  "3. CALLIGRAPHY MESSAGE & REAL BURGUNDY WAX SEAL",
                  style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.forestGreen),
                ),
                const SizedBox(height: 10),
                WaxSealMessage(
                  controller: _greetingController,
                  title: "Calligraphy Card",
                  hint: "E.g. \"Happy anniversary. You are my gold star.\" Our hand lettering artist will scribe this beautifully.",
                ),
                
                const SizedBox(height: 20),
                
                // Fine gold foil option
                Row(
                  children: [
                    Checkbox(
                      value: _wrapInGoldFoil,
                      onChanged: (val) {
                        setState(() => _wrapInGoldFoil = val ?? false);
                      },
                      activeColor: LuxuryTheme.emerald,
                      checkColor: LuxuryTheme.gold,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Wrap in Gold Foil and Silk Ribbon (+₹5.00)",
                            style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                          ),
                          Text(
                            "Polished gold-foil foil wrapped by hand, tied in a pure emerald silk bow.",
                            style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildPackagingRadio(GiftPackaging packaging, String title, String subtitle, double cost) {
    bool isSelected = _selectedPackaging == packaging;
    return InkWell(
      onTap: () {
        setState(() => _selectedPackaging = packaging);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? LuxuryTheme.creamText.withValues(alpha: 0.4) : Colors.transparent,
          border: Border.all(
            color: isSelected ? LuxuryTheme.gold : LuxuryTheme.warmSand.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<GiftPackaging>(
              value: packaging,
              groupValue: _selectedPackaging,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPackaging = val);
              },
              activeColor: LuxuryTheme.gold,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "+₹${cost.toStringAsFixed(0)}",
              style: LuxuryTheme.displayBrand(size: 11, color: LuxuriousItemPriceColor),
            ),
          ],
        ),
      ),
    );
  }

  static const Color LuxuriousItemPriceColor = LuxuryTheme.emerald;

  Widget _buildActionSection(BuildContext context) {
    final hasStock = widget.product.stock > 0;
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Selectors
              Row(
                children: [
                  _quantityButton(Icons.remove, () {
                    if (_itemQuantity > 1) setState(() => _itemQuantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _itemQuantity.toString(),
                      style: LuxuryTheme.displayBrand(size: 18, color: LuxuryTheme.forestGreen),
                    ),
                  ),
                  _quantityButton(Icons.add, () {
                    if (_itemQuantity < widget.product.stock) {
                      setState(() => _itemQuantity++);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("We currently only have limited handcrafted quantities left of this piece."),
                          backgroundColor: Color(0xFF8B1E2B),
                        ),
                      );
                    }
                  }),
                ],
              ),
              
              // Dynamic Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_enableGifting)
                    Text(
                      "Base: ₹${(widget.product.price * _itemQuantity).toStringAsFixed(0)}",
                      style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.grayMuted),
                    ),
                  Text(
                    "₹${_calculatedGrandTotal.toStringAsFixed(0)}",
                    style: LuxuryTheme.displayBrand(size: 20, color: LuxuryTheme.emerald),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Add to cart Button
          SizedBox(
            width: double.infinity,
            child: LuxuryButton(
              text: hasStock ? "Reserve & Add to Chest" : "Out of Vault Stock",
              onPressed: hasStock
                  ? () {
                      context.read<ShopProvider>().addToCart(
                            widget.product,
                            quantity: _itemQuantity,
                            giftPackaging: _enableGifting ? _selectedPackaging : GiftPackaging.none,
                            engravingText: _enableGifting && _engravingController.text.isNotEmpty
                                ? _engravingController.text
                                : null,
                            customGreetingMessage: _enableGifting && _greetingController.text.isNotEmpty
                                ? _greetingController.text
                                : null,
                            wrapInGoldFoil: _enableGifting ? _wrapInGoldFoil : false,
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: LuxuryTheme.emerald,
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: LuxuryTheme.gold),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Your piece has been tucked nicely into your Shopping Cart.",
                                  style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.creamText, bold: true),
                                ),
                              ),
                            ],
                          ),
                          action: SnackBarAction(
                            label: "VIEW CART",
                            textColor: LuxuryTheme.gold,
                            onPressed: () {
                              // Handled by client selection
                            },
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: LuxuryTheme.creamText,
          border: Border.all(color: LuxuryTheme.warmSand),
        ),
        child: Icon(icon, color: LuxuryTheme.forestGreen, size: 16),
      ),
    );
  }
}
