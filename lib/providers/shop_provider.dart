import 'dart:math';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  // Products Lists
  List<Product> _products = [];

  // Cart — populated for guests too; only synced to the backend once a
  // user is known (see _currentUserEmail).
  final List<CartItem> _cartItems = [];

  // Orders
  List<OrderModel> _orders = [];

  // Which consumer's cart/orders are currently loaded, if any. Null while
  // browsing as a guest or while viewing the admin portal.
  String? _currentUserEmail;

  bool _isBootstrapping = false;
  String? _errorMessage;

  // Filters & Sorting state
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _selectedCollection = "All";
  double _priceLimit = 10000.0;
  String _sortBy = "Featured"; // "Featured", "Price: Low to High", "Price: High to Low", "Popularity"

  // --- Getters ---
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<OrderModel> get orders => _orders;
  bool get isBootstrapping => _isBootstrapping;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCollection => _selectedCollection;
  double get priceLimit => _priceLimit;
  String get sortBy => _sortBy;

  String _generateSecureVaultCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final rand = Random();
    return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  // --- Bootstrap ---

  // Loads just the catalog. Safe to call as a guest — browsing needs no login.
  Future<void> bootstrapCatalog() async {
    _isBootstrapping = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await ApiService.fetchProducts();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isBootstrapping = false;
    notifyListeners();
  }

  // Loads the full catalog plus every order across all consumers (admin view).
  Future<void> bootstrapAdmin() async {
    _isBootstrapping = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await ApiService.fetchProducts();
      _orders = await ApiService.fetchOrders();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isBootstrapping = false;
    notifyListeners();
  }

  // Called right after a successful login/register. Merges whatever the
  // guest had already added to their cart with what's saved for this
  // account server-side, then loads that consumer's order history.
  Future<void> onUserAuthenticated(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    _currentUserEmail = normalizedEmail;
    _errorMessage = null;

    try {
      if (_products.isEmpty) {
        _products = await ApiService.fetchProducts();
      }

      final rawBackendItems = await ApiService.fetchCart(normalizedEmail);
      final backendItems = <CartItem>[];
      for (final raw in rawBackendItems) {
        final resolved = CartItem.fromApiJson(raw, _products);
        if (resolved != null) backendItems.add(resolved);
      }

      // Fold in anything the guest added locally before signing in.
      final guestItems = List<CartItem>.from(_cartItems);
      final merged = <CartItem>[...backendItems];
      for (final guestItem in guestItems) {
        final idx = merged.indexWhere((m) =>
            m.product.id == guestItem.product.id &&
            m.giftPackaging == guestItem.giftPackaging &&
            m.engravingText == guestItem.engravingText &&
            m.customGreetingMessage == guestItem.customGreetingMessage &&
            m.wrapInGoldFoil == guestItem.wrapInGoldFoil);
        if (idx != -1) {
          merged[idx].quantity += guestItem.quantity;
        } else {
          merged.add(guestItem);
        }
      }

      _cartItems
        ..clear()
        ..addAll(merged);
      await ApiService.saveCart(normalizedEmail, _cartItems);

      _orders = await ApiService.fetchOrders(email: normalizedEmail);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Called on logout. Catalog stays cached (harmless, avoids a reload
  // flash if they keep browsing as a guest); everything account-specific
  // is cleared.
  void reset() {
    _cartItems.clear();
    _orders = [];
    _currentUserEmail = null;
    resetFilters();
    notifyListeners();
  }

  // Re-fetches orders on demand — pass an email to refresh a consumer's own
  // history, or omit it for the admin "all orders" view.
  Future<void> refreshOrders({String? email}) async {
    try {
      _orders = await ApiService.fetchOrders(email: email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _syncCartInBackground() {
    final email = _currentUserEmail;
    if (email == null) return; // guest cart — nothing to sync yet
    ApiService.saveCart(email, _cartItems).catchError((_) {
      // Best-effort: a transient failure here isn't worth interrupting
      // the cart UI the user is actively interacting with.
    });
  }

  // Categories list derived from current products (+ "All")
  List<String> get categories {
    final allCats = _products.map((p) => p.category).toSet().toList();
    return ["All", ...allCats];
  }

  // Collections list derived from products
  List<String> get collections {
    final allColls = _products.map((p) => p.collection).toSet().toList();
    return ["All", ...allColls];
  }

  // Filtered and Sorted Products List
  List<Product> get filteredProducts {
    List<Product> results = [..._products];

    // Search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.gemstone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.metalType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.collection.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Category filter
    if (_selectedCategory != "All") {
      results = results.where((p) => p.category == _selectedCategory).toList();
    }

    // Collection filter
    if (_selectedCollection != "All") {
      results = results.where((p) => p.collection == _selectedCollection).toList();
    }

    // Price Limit
    results = results.where((p) => p.price <= _priceLimit).toList();

    // Sorting
    switch (_sortBy) {
      case "Price: Low to High":
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Price: High to Low":
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "Popularity":
        results.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
        break;
      case "Featured":
      default:
        results.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
        break;
    }

    return results;
  }

  // --- Filtering actions ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedCollection(String collection) {
    _selectedCollection = collection;
    notifyListeners();
  }

  void setPriceLimit(double limit) {
    _priceLimit = limit;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = "";
    _selectedCategory = "All";
    _selectedCollection = "All";
    _priceLimit = 10000.0;
    _sortBy = "Featured";
    notifyListeners();
  }

  // --- Cart Actions (instant locally; synced to the backend in the
  // background whenever a consumer is signed in) ---
  void addToCart(
    Product product, {
    int quantity = 1,
    GiftPackaging giftPackaging = GiftPackaging.none,
    String? engravingText,
    String? customGreetingMessage,
    bool wrapInGoldFoil = false,
  }) {
    final index = _cartItems.indexWhere((item) =>
      item.product.id == product.id &&
      item.giftPackaging == giftPackaging &&
      item.engravingText == engravingText &&
      item.customGreetingMessage == customGreetingMessage &&
      item.wrapInGoldFoil == wrapInGoldFoil
    );

    if (index != -1) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        giftPackaging: giftPackaging,
        engravingText: engravingText,
        customGreetingMessage: customGreetingMessage,
        wrapInGoldFoil: wrapInGoldFoil,
      ));
    }
    notifyListeners();
    _syncCartInBackground();
  }

  void updateCartItem(CartItem item, {
    int? quantity,
    GiftPackaging? giftPackaging,
    String? engravingText,
    String? customGreetingMessage,
    bool? wrapInGoldFoil,
  }) {
    final idx = _cartItems.indexOf(item);
    if (idx != -1) {
      _cartItems[idx] = _cartItems[idx].copyWith(
        quantity: quantity,
        giftPackaging: giftPackaging,
        engravingText: engravingText,
        customGreetingMessage: customGreetingMessage,
        wrapInGoldFoil: wrapInGoldFoil,
      );
      notifyListeners();
      _syncCartInBackground();
    }
  }

  void updateCartItemQuantity(CartItem item, int delta) {
    final idx = _cartItems.indexOf(item);
    if (idx != -1) {
      final newQty = _cartItems[idx].quantity + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(idx);
      } else {
        _cartItems[idx].quantity = newQty;
      }
      notifyListeners();
      _syncCartInBackground();
    }
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
    _syncCartInBackground();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _syncCartInBackground();
  }

  double get cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get cartGiftCustomizationTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.packagingPrice * item.quantity + (item.wrapInGoldFoil ? 5.0 * item.quantity : 0.0));
  }

  double get cartTax {
    // 8% Luxury Tax on jewellery and personalization
    return (cartSubtotal + cartGiftCustomizationTotal) * 0.08;
  }

  double get cartGrandTotal {
    return cartSubtotal + cartGiftCustomizationTotal + cartTax; // Complimentary tracked armored delivery ($0)
  }

  // --- Order Placement (requires a signed-in consumer; enforced by the
  // checkout gate in the UI, not here) ---
  Future<OrderModel> submitOrder({
    required String fullName,
    required String addressLine1,
    required String city,
    required String postalCode,
    required String phone,
    String? paymentMethod,
  }) async {
    final email = _currentUserEmail;
    if (email == null) {
      throw StateError("submitOrder called without a signed-in consumer.");
    }

    final orderItems = _cartItems.map((item) {
      return OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        category: item.product.category,
        basePrice: item.product.price,
        quantity: item.quantity,
        packagingName: item.packagingName,
        packagingPrice: item.packagingPrice,
        engravingText: item.engravingText,
        customGreetingMessage: item.customGreetingMessage,
        wrapInGoldFoil: item.wrapInGoldFoil,
        imageUrl: item.product.imageUrl,
      );
    }).toList();

    final draft = OrderModel(
      id: "ORD-${Random().nextInt(90000) + 10000}",
      email: email,
      orderDate: DateTime.now(),
      items: orderItems,
      subtotal: cartSubtotal,
      giftCustomizationTotal: cartGiftCustomizationTotal,
      deliveryCharge: 0.0,
      tax: cartTax,
      grandTotal: cartGrandTotal,
      fullName: fullName,
      addressLine1: addressLine1,
      city: city,
      postalCode: postalCode,
      phone: phone,
      secureVaultCode: _generateSecureVaultCode(),
      paymentMethod: paymentMethod,
      status: OrderStatus.ordered,
    );

    final created = await ApiService.createOrder(draft);
    _orders.insert(0, created);

    _cartItems.clear();
    await ApiService.saveCart(email, _cartItems);

    // Stock was decremented server-side; refresh so the UI reflects it.
    try {
      _products = await ApiService.fetchProducts();
    } catch (_) {
      // Non-fatal — stock will just look stale until the next reload.
    }

    notifyListeners();
    return created;
  }

  // --- Admin Methods ---
  Future<void> addProduct(Product product) async {
    final created = await ApiService.createProduct(product);
    _products.insert(0, created);
    notifyListeners();
  }

  Future<void> updateProduct(Product updated) async {
    final saved = await ApiService.updateProduct(updated);
    final idx = _products.indexWhere((p) => p.id == saved.id);
    if (idx != -1) {
      _products[idx] = saved;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await ApiService.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final mongoId = _orders[idx].mongoId;
    if (mongoId == null) return;
    final updated = await ApiService.updateOrderStatus(mongoId, newStatus);
    _orders[idx] = updated;
    notifyListeners();
  }

  Future<void> updateOrderItemStatus(String orderId, int itemIndex, OrderStatus newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final mongoId = _orders[idx].mongoId;
    if (mongoId == null) return;
    final updated = await ApiService.updateOrderItemStatus(mongoId, itemIndex, newStatus);
    _orders[idx] = updated;
    notifyListeners();
  }

  // Admin Analytics Getters
  double get adminTotalRevenue {
    return _orders.fold(0.0, (sum, order) => sum + order.grandTotal);
  }

  int get adminTotalItemsSold {
    int total = 0;
    for (var o in _orders) {
      for (var item in o.items) {
        total += item.quantity;
      }
    }
    return total;
  }

  // No account registry is synced from Firebase into the backend, so
  // "users" is approximated as distinct customers who have placed an order.
  int get adminTotalCustomers {
    return _orders.map((o) => o.email).toSet().length;
  }

  int get adminPendingOrdersCount {
    return _orders.where((o) => o.status != OrderStatus.delivered).length;
  }

  Map<String, int> get adminCategorySales {
    Map<String, int> sales = {};
    for (var o in _orders) {
      for (var item in o.items) {
        sales[item.category] = (sales[item.category] ?? 0) + item.quantity;
      }
    }
    return sales;
  }
}
