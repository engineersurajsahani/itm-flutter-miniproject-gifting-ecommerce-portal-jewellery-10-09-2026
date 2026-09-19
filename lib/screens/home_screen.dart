import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/shop_provider.dart';
import '../models/product.dart';
import '../widgets/luxury_divider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final products = provider.filteredProducts;

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : 2;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: LuxuryTheme.gold,
          backgroundColor: LuxuryTheme.forestGreen,
          onRefresh: () async {
            provider.resetFilters();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. High-fidelity Luxury App Bar with Custom Search
              SliverToBoxAdapter(
                child: _buildLuxuryHeader(context),
              ),

              // 2. Beautiful Promotional Carousel Card
              SliverToBoxAdapter(
                child: _buildPromoBanner(context),
              ),

              // 3. Elegant Search Bar with Custom borders
              SliverToBoxAdapter(
                child: _buildSearchBarAndFilters(context, provider),
              ),

              // 4. Horizontal Categories Browsing
              SliverToBoxAdapter(
                child: _buildCategoryChips(context, provider),
              ),

              // 5. Featured Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        provider.selectedCategory == "All"
                            ? "THE ROYAL COLLECTION"
                            : "${provider.selectedCategory.toUpperCase()} COLLECTION",
                        style: LuxuryTheme.headlineElegant(size: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const LuxuryDivider(width: 60),
                    ],
                  ),
                ),
              ),

              // 6. Grid Listings of gorgeous products
              products.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.diamond_outlined,
                              size: 48,
                              color: LuxuryTheme.warmSand,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No precious metals match your inquiry.",
                              style: LuxuryTheme.bodySerif(size: 16, color: LuxuryTheme.forestGreen),
                            ),
                            TextButton(
                              onPressed: () => provider.resetFilters(),
                              child: Text(
                                "RESET INQUIRY",
                                style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).size.width > 850 ? 24 : 110, // Avoid floated bottom nav
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return _buildProductCard(context, product);
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: LuxuryTheme.forestGreen,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AURELIA",
                    style: LuxuryTheme.displayBrand(size: 26, color: LuxuryTheme.gold),
                  ),
                  Text(
                    "Maison de Haute Joaillerie",
                    style: LuxuryTheme.bodySerif(size: 13, color: LuxuryTheme.cream.withValues(alpha: 0.8)),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.4), width: 1),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.stars_rounded,
                  color: LuxuryTheme.gold,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryTheme.forestGreen,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.3), width: 1),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 10),
      ),
      child: Stack(
        children: [
          // Background elegant image of jewelry craftsmanship
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.network(
                "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&q=80&w=1200",
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Subtle Gold Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LuxuryTheme.forestGreen.withValues(alpha: 0.95),
                    LuxuryTheme.forestGreen.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: LuxuryTheme.gold,
                  child: Text(
                    "CURATED AUTUMN GIFTS",
                    style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.forestGreen),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "The Royal Emerald\nCollection",
                  style: LuxuryTheme.headlineElegant(size: 24, color: LuxuryTheme.cream),
                ),
                const SizedBox(height: 8),
                Text(
                  "Experience physical 18K Green Gold items handmolded to fit sovereign stones.",
                  style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.cream.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilters(BuildContext context, ShopProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: LuxuryTheme.whitePremium,
              border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
            ),
            child: TextField(
              onChanged: (val) => provider.setSearchQuery(val),
              cursorColor: LuxuryTheme.forestGreen,
              decoration: InputDecoration(
                hintText: "Search rings, necklaces, gemstones...",
                hintStyle: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: LuxuryTheme.gold),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => provider.setSearchQuery(""),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Row of filter info containing sorting & collection filtering
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${provider.filteredProducts.length} items",
                style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
              ),
              
              // Sort dropdown trigger
              PopupMenuButton<String>(
                color: LuxuryTheme.whitePremium,
                surfaceTintColor: Colors.transparent,
                onSelected: (String value) {
                  provider.setSortBy(value);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: "Featured",
                    child: Text("Curated Featured"),
                  ),
                  const PopupMenuItem<String>(
                    value: "Price: Low to High",
                    child: Text("Price: Low to High"),
                  ),
                  const PopupMenuItem<String>(
                    value: "Price: High to Low",
                    child: Text("Price: High to Low"),
                  ),
                  const PopupMenuItem<String>(
                    value: "Popularity",
                    child: Text("Most Celebrated"),
                  ),
                ],
                child: Row(
                  children: [
                    Text(
                      provider.sortBy.toUpperCase(),
                      style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: LuxuryTheme.gold, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, ShopProvider provider) {
    final cats = provider.categories;
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cur = cats[index];
          final isSelected = provider.selectedCategory == cur;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              backgroundColor: LuxuryTheme.cream,
              selectedColor: LuxuryTheme.forestGreen,
              shadowColor: Colors.transparent,
              checkmarkColor: LuxuryTheme.gold,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              side: BorderSide(
                color: isSelected ? LuxuryTheme.gold : LuxuryTheme.warmSand,
                width: 1,
              ),
              label: Text(
                cur.toUpperCase(),
                style: LuxuryTheme.displayBrand(
                  size: 10,
                  color: isSelected ? LuxuryTheme.gold : LuxuryTheme.forestGreen,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                provider.setSelectedCategory(cur);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: LuxuryTheme.whitePremium,
          border: Border.all(color: LuxuryTheme.warmSand.withValues(alpha: 0.7), width: 1.5),
          boxShadow: LuxuryTheme.luxuryShadow(blur: 8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image and tags
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'prod-image-${product.id}',
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (product.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: LuxuryTheme.emerald,
                        child: Text(
                          "VAULT SELECTION",
                          style: LuxuryTheme.displayBrand(size: 7, color: LuxuryTheme.gold),
                        ),
                      ),
                    ),
                  
                  if (product.stock <= 2 && product.stock > 0)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        color: const Color(0xFF8B1E2B), // Luxury warning crimson
                        child: Text(
                          "LAST ${product.stock} PIECES",
                          style: LuxuryTheme.displayBrand(size: 7, color: LuxuryTheme.cream),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Information
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.collection.toUpperCase(),
                    style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: LuxuryTheme.headlineElegant(size: 15, color: LuxuryTheme.forestGreen),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Gems details
                  Text(
                    "${product.gemstone} • ${product.metalType}",
                    style: LuxuryTheme.bodySerif(size: 12, color: LuxuryTheme.grayMuted, bold: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  
                  // Price Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${product.price.toStringAsFixed(0)}",
                        style: LuxuryTheme.displayBrand(size: 14, color: LuxuryTheme.forestGreen),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: LuxuryTheme.gold, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.blackJet, bold: true),
                          ),
                        ],
                      ),
                    ],
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
