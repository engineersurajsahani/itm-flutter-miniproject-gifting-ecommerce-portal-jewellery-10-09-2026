import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/shop_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainRootScreen extends StatefulWidget {
  final int initialIndex;

  const MainRootScreen({super.key, this.initialIndex = 0});

  @override
  State<MainRootScreen> createState() => _MainRootScreenState();
}

class _MainRootScreenState extends State<MainRootScreen> {
  late int _currentIndex = widget.initialIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // The catalog is public — load it regardless of whether anyone is signed
    // in. Deferred to after the first frame since bootstrapCatalog's initial
    // notifyListeners() would otherwise fire mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ShopProvider>().bootstrapCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    if (provider.isBootstrapping && provider.products.isEmpty) {
      return Scaffold(
        backgroundColor: LuxuryTheme.forestGreen,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: LuxuryTheme.gold),
              const SizedBox(height: 20),
              Text(
                "OPENING THE BOUTIQUE",
                style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    }

    // Collect screen width to support mobile-first responsiveness transitioning into desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                // Elegant Left Navigation Sidebar for Desktop
                Container(
                  width: 260,
                  color: LuxuryTheme.forestGreen,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      // Brand Identity
                      Text(
                        "AURELIA",
                        style: LuxuryTheme.displayBrand(size: 24, color: LuxuryTheme.gold),
                      ),
                      Text(
                        "MAISON DE JOAILLERIE",
                        style: LuxuryTheme.displayBrand(size: 7, color: LuxuryTheme.gold.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(
                        width: 140,
                        child: Divider(color: LuxuryTheme.gold, thickness: 0.5),
                      ),
                      const SizedBox(height: 36),

                      // Desktop Navigation Links
                      _buildDesktopNavItem(0, "The Boutique", Icons.storefront_outlined),
                      const SizedBox(height: 12),
                      _buildDesktopNavItem(
                        1,
                        "Shopping Cart",
                        Icons.shopping_bag_outlined,
                        badgeCount: context.watch<ShopProvider>().cartItems.length,
                      ),
                      const SizedBox(height: 12),
                      _buildDesktopNavItem(2, "My Profile", Icons.person_outline_rounded),

                      const Spacer(),

                      // Elegant details inside sidebar
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              "SECURED GOLD STANDARD",
                              style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold.withValues(alpha: 0.6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Insured Armored Logistics",
                              style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.cream.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Screen Component
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screens[_currentIndex],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                // Mobile viewport screen content
                _screens[_currentIndex],

                // Floated Mobile Navigation Bar for an incredibly modern look
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: LuxuryTheme.forestGreen,
                      border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: LuxuryTheme.blackJet.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildMobileNavButton(0, Icons.storefront_outlined, "Boutique")),
                        Expanded(
                          child: _buildMobileNavButton(
                            1,
                            Icons.shopping_bag_outlined,
                            "Cart",
                            badgeCount: context.watch<ShopProvider>().cartItems.length,
                          ),
                        ),
                        Expanded(child: _buildMobileNavButton(2, Icons.person_outline_rounded, "Profile")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopNavItem(int index, String label, IconData icon, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? LuxuryTheme.gold.withValues(alpha: 0.12) : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: LuxuryTheme.gold, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? LuxuryTheme.gold : LuxuryTheme.cream.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: LuxuryTheme.displayBrand(
                  size: 11,
                  color: isSelected ? LuxuryTheme.gold : LuxuryTheme.cream.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: LuxuryTheme.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: LuxuryTheme.forestGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavButton(int index, IconData icon, String label, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? LuxuryTheme.gold.withValues(alpha: 0.15) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? LuxuryTheme.gold : LuxuryTheme.cream.withValues(alpha: 0.6),
                    size: isSelected ? 24 : 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: LuxuryTheme.displayBrand(
                    size: 8,
                    color: isSelected ? LuxuryTheme.gold : LuxuryTheme.cream.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: -3,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: LuxuryTheme.gold,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: LuxuryTheme.forestGreen, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
