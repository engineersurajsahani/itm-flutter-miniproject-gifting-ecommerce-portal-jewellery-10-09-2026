import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../widgets/luxury_divider.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ShopProvider>().bootstrapAdmin();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showErrorSnack(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ApiException ? error.message : "Something went wrong."),
        backgroundColor: const Color(0xFF8B1E2B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;

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
                "OPENING THE EXECUTIVE LOUNGE",
                style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.gold.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AURELIA EXECUTIVE EXECUTIVE LOUNGE",
          style: LuxuryTheme.displayBrand(size: 13, color: LuxuryTheme.cream),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: LuxuryTheme.gold,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh_rounded, color: LuxuryTheme.gold),
            onPressed: () => provider.bootstrapAdmin(),
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout_rounded, color: LuxuryTheme.gold),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.read<ShopProvider>().reset();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: LuxuryTheme.gold,
          labelColor: LuxuryTheme.gold,
          unselectedLabelColor: LuxuryTheme.cream.withValues(alpha: 0.6),
          tabs: [
            Tab(
              icon: const Icon(Icons.analytics_outlined, size: 18),
              child: Text(
                "ANALYTICS",
                style: LuxuryTheme.displayBrand(size: 9, color: Colors.transparent),
              ),
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              child: Text(
                "INVENTORY",
                style: LuxuryTheme.displayBrand(size: 9, color: Colors.transparent),
              ),
            ),
            Tab(
              icon: const Icon(Icons.history_edu_rounded, size: 18),
              child: Text(
                "CLIENT ORDERS",
                style: LuxuryTheme.displayBrand(size: 9, color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalyticsTab(provider, isDesktop),
            _buildInventoryTab(provider, context, isDesktop),
            _buildOrdersTab(provider, context, isDesktop),
          ],
        ),
      ),
    );
  }

  // ============== TAB A: ANALYTICS ==============
  Widget _buildAnalyticsTab(ShopProvider provider, bool isDesktop) {
    final totalRevenue = provider.adminTotalRevenue;
    final totalItemsSold = provider.adminTotalItemsSold;
    final ordersCount = provider.orders.length;
    final categorySales = provider.adminCategorySales;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Maison Revenue Analytics & Sovereign Bullion Metrics",
            style: LuxuryTheme.headlineElegant(size: 18, color: LuxuryTheme.forestGreen),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const LuxuryDivider(width: 80),
          const SizedBox(height: 24),

          // Numeric KPI Cards
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: isDesktop ? 3 : 1,
            childAspectRatio: isDesktop ? 2.2 : 2.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildKPICard(
                "TOTAL LEDGER REVENUE",
                "₹${totalRevenue.toStringAsFixed(2)}",
                Icons.account_balance_wallet_outlined,
                LuxuryTheme.goldGradient,
              ),
              _buildKPICard(
                "SOVEREIGN CLIENT ORDERS",
                ordersCount.toString(),
                Icons.receipt_long_outlined,
                const LinearGradient(colors: [LuxuryTheme.emerald, LuxuryTheme.forestGreen]),
              ),
              _buildKPICard(
                "PRECIOUS ITEMS RELEASED",
                totalItemsSold.toString(),
                Icons.diamond_outlined,
                const LinearGradient(colors: [Color(0xFF8B1E2B), Color(0xFF5A0E18)]),
              ),
              _buildKPICard(
                "TOTAL SOVEREIGN CLIENTS",
                provider.adminTotalCustomers.toString(),
                Icons.people_outline_rounded,
                const LinearGradient(colors: [Color(0xFF4A5D45), Color(0xFF2C3A28)]),
              ),
              _buildKPICard(
                "ORDERS AWAITING DELIVERY",
                provider.adminPendingOrdersCount.toString(),
                Icons.local_shipping_outlined,
                const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFF7A5A08)]),
              ),
            ],
          ),

          const SizedBox(height: 32),
          
          // Sales by category chart simulation
          _buildCategoryAnalyticsCard(categorySales, isDesktop),
          const SizedBox(height: 110), // Padding avoiding navbar
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Gradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        border: Border.all(color: LuxuryTheme.warmSand.withValues(alpha: 0.5)),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 10),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LuxuryTheme.whitePremium.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LuxuryTheme.cream, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.cream.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: LuxuryTheme.displayBrand(size: 16, color: LuxuryTheme.cream),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAnalyticsCard(Map<String, int> categorySales, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CRAFT DESIGNS SALES SPREAD",
            style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
          ),
          const SizedBox(height: 8),
          Text(
            "A representation of the relative demand for metal divisions.",
            style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.grayMuted),
          ),
          const SizedBox(height: 24),

          if (categorySales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  "No sales registered in logs yet.",
                  style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
                ),
              ),
            )
          else if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCategoryPieChart(categorySales),
                const SizedBox(width: 40),
                Expanded(child: _buildCategoryLegend(categorySales)),
              ],
            )
          else
            Column(
              children: [
                _buildCategoryPieChart(categorySales),
                const SizedBox(height: 24),
                _buildCategoryLegend(categorySales),
              ],
            ),
        ],
      ),
    );
  }

  static const List<Color> _pieSliceColors = [
    LuxuryTheme.gold,
    LuxuryTheme.emerald,
    LuxuryTheme.forestGreen,
    Color(0xFFB8860B),
    Color(0xFF8B1E2B),
  ];

  Widget _buildCategoryPieChart(Map<String, int> categorySales) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(painter: _CategoryPieChartPainter(categorySales, _pieSliceColors)),
    );
  }

  Widget _buildCategoryLegend(Map<String, int> categorySales) {
    final entries = categorySales.entries.toList();
    final total = categorySales.values.fold(0, (sum, val) => sum + val);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _pieSliceColors[i % _pieSliceColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entries[i].key.toUpperCase(),
                    style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                  ),
                ),
                Text(
                  "${entries[i].value} (${total > 0 ? (entries[i].value / total * 100).toStringAsFixed(0) : '0'}%)",
                  style: LuxuryTheme.bodySans(size: 13, bold: true),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============== TAB B: INVENTORY ==============
  Widget _buildInventoryTab(ShopProvider provider, BuildContext context, bool isDesktop) {
    final products = provider.products;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Actions Header
              Container(
                decoration: BoxDecoration(
                  color: LuxuryTheme.cream,
                  border: Border(bottom: BorderSide(color: LuxuryTheme.warmSand)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Maison Stock Vault: ${products.length} Designs",
                      style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.forestGreen, bold: true),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: LuxuryTheme.gold, size: 18),
                      label: Text(
                        "ADD NEW PIECE",
                        style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.forestGreen),
                      ),
                      onPressed: () {
                        _showAddProductDialog(context, provider);
                      },
                    ),
                  ],
                ),
              ),

              // Spreadsheet Inventory Grid Lists
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: LuxuryTheme.whitePremium,
                        border: Border.all(color: LuxuryTheme.warmSand.withValues(alpha: 0.5)),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: LuxuryTheme.warmSand),
                          ),
                          child: Image.network(product.imageUrl, fit: BoxFit.cover),
                        ),
                        title: Text(
                          product.name,
                          style: LuxuryTheme.headlineElegant(size: 15, color: LuxuryTheme.forestGreen),
                        ),
                        subtitle: Text(
                          "${product.collection} • ${product.gemstone} • Weight: ${product.weight}g",
                          style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show current stock inside editable capsule
                            GestureDetector(
                              onTap: () {
                                _showUpdateStockDialog(context, provider, product);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.stock == 0
                                      ? const Color(0xFF8B1E2B).withValues(alpha: 0.12)
                                      : LuxuryTheme.cream,
                                  border: Border.all(color: LuxuryTheme.warmSand),
                                ),
                                child: Text(
                                  "STOCK: ${product.stock}",
                                  style: LuxuryTheme.displayBrand(
                                    size: 9, 
                                    color: product.stock == 0 ? const Color(0xFF8B1E2B) : LuxuryTheme.forestGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Update price
                            IconButton(
                              icon: const Icon(Icons.edit_note_outlined, color: LuxuryTheme.gold),
                              onPressed: () {
                                _showEditProductDialog(context, provider, product);
                              },
                            ),

                            // Delete Design
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFF8B1E2B)),
                              onPressed: () async {
                                try {
                                  await provider.deleteProduct(product.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Design removed from vault stock immediately: ${product.name}"),
                                      backgroundColor: LuxuryTheme.emerald,
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  _showErrorSnack(e);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 110), // Scroll overlap padding
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateStockDialog(BuildContext context, ShopProvider provider, Product product) {
    int updatedStock = product.stock;
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: LuxuryTheme.cream,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text("ADJUST PHYSICAL VAULT STOCK", style: LuxuryTheme.displayBrand(size: 11)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (updatedStock > 0) setState(() => updatedStock--);
                    },
                  ),
                  Text(
                    updatedStock.toString(),
                    style: LuxuryTheme.displayBrand(size: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => updatedStock++);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("CANCEL", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.grayMuted)),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    try {
                      await provider.updateProduct(product.copyWith(stock: updatedStock));
                      navigator.pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      _showErrorSnack(e);
                    }
                  },
                  child: Text("LOCK STOCK IN", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.emerald)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context, ShopProvider provider) {
    final nameCont = TextEditingController();
    final colCont = TextEditingController();
    final priceCont = TextEditingController();
    final gemCont = TextEditingController();
    final metCont = TextEditingController();
    final weightCont = TextEditingController();
    final descCont = TextEditingController();
    final imgCont = TextEditingController(text: "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&q=80&w=600");
    String cat = "Rings";
    int stock = 5;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: LuxuryTheme.cream,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text("ADD NEW ARTISANAL CREATION", style: LuxuryTheme.displayBrand(size: 12)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCont, decoration: const InputDecoration(labelText: "Design Display Name")),
                TextField(controller: colCont, decoration: const InputDecoration(labelText: "Exquisite Collection")),
                DropdownButtonFormField<String>(
                  initialValue: cat,
                  onChanged: (val) {
                    if (val != null) cat = val;
                  },
                  items: ["Rings", "Necklaces", "Bracelets", "Earrings"].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  decoration: const InputDecoration(labelText: "Category Classification"),
                ),
                TextField(controller: priceCont, decoration: const InputDecoration(labelText: r"Price (₹)"), keyboardType: TextInputType.number),
                TextField(controller: gemCont, decoration: const InputDecoration(labelText: "Fine Gemstone details")),
                TextField(controller: metCont, decoration: const InputDecoration(labelText: "Metal material details")),
                TextField(controller: weightCont, decoration: const InputDecoration(labelText: "Weight (grams)"), keyboardType: TextInputType.number),
                TextField(controller: descCont, decoration: const InputDecoration(labelText: "Romantic Slogan & Description")),
                TextField(controller: imgCont, decoration: const InputDecoration(labelText: "Unsplash Image Cover Link")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ABORT", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.grayMuted)),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final double pr = double.tryParse(priceCont.text) ?? 1000.0;
                final double wt = double.tryParse(weightCont.text) ?? 5.5;
                final newProd = Product(
                  id: "", // assigned by the backend
                  name: nameCont.text.isEmpty ? "Curated Creation" : nameCont.text,
                  collection: colCont.text.isEmpty ? "Artisanal Classics" : colCont.text,
                  description: descCont.text.isEmpty ? "A luxurious and beautifully molded jewelry." : descCont.text,
                  price: pr,
                  category: cat,
                  imageUrl: imgCont.text,
                  rating: 5.0,
                  reviewsCount: 1,
                  metalType: metCont.text.isEmpty ? "18K Gold" : metCont.text,
                  gemstone: gemCont.text.isEmpty ? "Certified Diamonds" : gemCont.text,
                  weight: wt,
                  stock: stock,
                  isFeatured: true,
                );
                try {
                  await provider.addProduct(newProd);
                  navigator.pop();
                } catch (e) {
                  if (!context.mounted) return;
                  _showErrorSnack(e);
                }
              },
              child: Text("EXPAND COLLECTION", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, ShopProvider provider, Product product) {
    final priceCont = TextEditingController(text: product.price.toStringAsFixed(0));
    final descCont = TextEditingController(text: product.description);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: LuxuryTheme.cream,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text("MODIFY DESIGN VALUES", style: LuxuryTheme.displayBrand(size: 11)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: priceCont, decoration: const InputDecoration(labelText: r"Adjust price tag (₹)"), keyboardType: TextInputType.number),
              TextField(controller: descCont, decoration: const InputDecoration(labelText: "Tweak jewelry descriptions")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("CANCEL", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.grayMuted)),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final pr = double.tryParse(priceCont.text) ?? product.price;
                try {
                  await provider.updateProduct(product.copyWith(
                    price: pr,
                    description: descCont.text,
                  ));
                  navigator.pop();
                } catch (e) {
                  if (!context.mounted) return;
                  _showErrorSnack(e);
                }
              },
              child: Text("APPLY CHANGES", style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.emerald)),
            ),
          ],
        );
      },
    );
  }

  // ============== TAB C: EXECUTIVE ORDERS ==============
  Widget _buildOrdersTab(ShopProvider provider, BuildContext context, bool isDesktop) {
    final orders = provider.orders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: LuxuryTheme.cream,
            border: Border(bottom: BorderSide(color: LuxuryTheme.warmSand)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            "Customer Transaction Submissions: ${orders.length} Entries",
            style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.forestGreen, bold: true),
          ),
        ),

        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    "No orders currently submitted for processing.",
                    style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(provider, context, order);
                  },
                ),
        ),
        const SizedBox(height: 110),
      ],
    );
  }

  // A single checkout instance: every item bought together in that order,
  // grouped under the customer, order id, combined quantity and price.
  Widget _buildOrderCard(ShopProvider provider, BuildContext context, OrderModel order) {
    final totalQty = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.fullName,
                      style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.blackJet, bold: true),
                    ),
                    Text(
                      order.email,
                      style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "QTY: $totalQty",
                    style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.grayMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${order.grandTotal.toStringAsFixed(2)}",
                    style: LuxuryTheme.displayBrand(size: 13, color: LuxuryTheme.emerald),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: LuxuryTheme.cream, height: 1),
          const SizedBox(height: 8),

          // Every item ordered together in this instance, each with its own
          // thumbnail and independently adjustable delivery status.
          ...order.items.asMap().entries.map((entry) {
            return _buildOrderItemRow(provider, context, order, entry.key, entry.value);
          }),

          const SizedBox(height: 8),
          Divider(color: LuxuryTheme.cream, height: 1),
          const SizedBox(height: 8),

          Text(
            "Delivery Address: ${order.addressLine1}, ${order.city}",
            style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(
    ShopProvider provider,
    BuildContext context,
    OrderModel order,
    int itemIndex,
    OrderItem item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(border: Border.all(color: LuxuryTheme.warmSand)),
            child: Image.network(item.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.productName} (x${item.quantity})",
                  style: LuxuryTheme.bodySerif(size: 13, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.engravingText != null)
                  Text(
                    'Engraving: "${item.engravingText}"',
                    style: LuxuryTheme.bodySans(size: 10, color: LuxuryTheme.grayMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delivered is final — once set, it's locked and can no longer be
          // reverted or changed to a different stage.
          if (item.status == OrderStatus.delivered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: LuxuryTheme.emerald.withValues(alpha: 0.12),
                border: Border.all(color: LuxuryTheme.emerald),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 11, color: LuxuryTheme.emerald),
                  const SizedBox(width: 4),
                  Text(
                    "DELIVERED",
                    style: TextStyle(
                      color: LuxuryTheme.emerald,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButton<OrderStatus>(
              value: item.status,
              isDense: true,
              dropdownColor: LuxuryTheme.whitePremium,
              onChanged: (OrderStatus? newStatus) async {
                if (newStatus == null) return;
                try {
                  await provider.updateOrderItemStatus(order.id, itemIndex, newStatus);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${item.productName} marked ${_getOrderStatusLabel(newStatus)}"),
                      backgroundColor: LuxuryTheme.emerald,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  _showErrorSnack(e);
                }
              },
              items: OrderStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    _getOrderStatusLabel(status).toUpperCase(),
                    style: TextStyle(
                      color: status == OrderStatus.delivered ? LuxuryTheme.emerald : LuxuryTheme.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getOrderStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return "Ordered";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.outForDelivery:
        return "Out for Delivery";
      case OrderStatus.delivered:
        return "Delivered";
    }
  }
}

class _CategoryPieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;

  _CategoryPieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -pi / 2;
    int i = 0;
    for (final value in data.values) {
      final sweepAngle = (value / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
      i++;
    }

    // Donut hole, cut from the center of the pie.
    final holePaint = Paint()..color = LuxuryTheme.whitePremium;
    canvas.drawCircle(rect.center, size.width * 0.32, holePaint);
  }

  @override
  bool shouldRepaint(covariant _CategoryPieChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.colors != colors;
  }
}
