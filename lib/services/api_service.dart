import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/cart.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthResult {
  final bool isAdmin;
  final String? fullName;
  final String? email;

  AuthResult({required this.isAdmin, this.fullName, this.email});
}

class ApiService {
  static const String baseUrl = "http://localhost:4000/api";

  static Map<String, String> get _jsonHeaders => {"Content-Type": "application/json"};

  static Never _throwFromResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error'] as String? ?? "Something went wrong (${response.statusCode}).");
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException("Something went wrong (${response.statusCode}).");
    }
  }

  static Future<T> _wrapNetworkErrors<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException("Couldn't reach the server. Is the backend running?");
    }
  }

  // --- Auth ---

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _wrapNetworkErrors(() async {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: _jsonHeaders,
        body: jsonEncode({"fullName": fullName, "email": email, "password": password}),
      );
      if (response.statusCode != 201) _throwFromResponse(response);
    });
  }

  static Future<AuthResult> login({required String email, required String password}) {
    return _wrapNetworkErrors(() async {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: _jsonHeaders,
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode != 200) _throwFromResponse(response);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final isAdmin = body['role'] == 'admin';
      return AuthResult(
        isAdmin: isAdmin,
        fullName: body['fullName'] as String?,
        email: body['email'] as String?,
      );
    });
  }

  // --- Products ---

  static Future<List<Product>> fetchProducts() {
    return _wrapNetworkErrors(() async {
      final response = await http.get(Uri.parse("$baseUrl/products"));
      if (response.statusCode != 200) _throwFromResponse(response);
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  static Future<Product> createProduct(Product product) {
    return _wrapNetworkErrors(() async {
      final response = await http.post(
        Uri.parse("$baseUrl/products"),
        headers: _jsonHeaders,
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode != 201) _throwFromResponse(response);
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    });
  }

  static Future<Product> updateProduct(Product product) {
    return _wrapNetworkErrors(() async {
      final response = await http.put(
        Uri.parse("$baseUrl/products/${product.id}"),
        headers: _jsonHeaders,
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode != 200) _throwFromResponse(response);
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    });
  }

  static Future<void> deleteProduct(String id) {
    return _wrapNetworkErrors(() async {
      final response = await http.delete(Uri.parse("$baseUrl/products/$id"));
      if (response.statusCode != 204) _throwFromResponse(response);
    });
  }

  // --- Orders ---

  static Future<List<OrderModel>> fetchOrders({String? email}) {
    return _wrapNetworkErrors(() async {
      final uri = email == null
          ? Uri.parse("$baseUrl/orders")
          : Uri.parse("$baseUrl/orders").replace(queryParameters: {"email": email});
      final response = await http.get(uri);
      if (response.statusCode != 200) _throwFromResponse(response);
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  static Future<OrderModel> createOrder(OrderModel order) {
    return _wrapNetworkErrors(() async {
      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: _jsonHeaders,
        body: jsonEncode(order.toJson()),
      );
      if (response.statusCode != 201) _throwFromResponse(response);
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    });
  }

  static Future<OrderModel> updateOrderStatus(String mongoId, OrderStatus status) {
    return _wrapNetworkErrors(() async {
      final response = await http.patch(
        Uri.parse("$baseUrl/orders/$mongoId/status"),
        headers: _jsonHeaders,
        body: jsonEncode({"status": status.name}),
      );
      if (response.statusCode != 200) _throwFromResponse(response);
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    });
  }

  static Future<OrderModel> updateOrderItemStatus(String mongoId, int itemIndex, OrderStatus status) {
    return _wrapNetworkErrors(() async {
      final response = await http.patch(
        Uri.parse("$baseUrl/orders/$mongoId/items/$itemIndex/status"),
        headers: _jsonHeaders,
        body: jsonEncode({"status": status.name}),
      );
      if (response.statusCode != 200) _throwFromResponse(response);
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    });
  }

  // --- Cart ---

  static Future<List<Map<String, dynamic>>> fetchCart(String email) {
    return _wrapNetworkErrors(() async {
      final response = await http.get(Uri.parse("$baseUrl/cart/$email"));
      if (response.statusCode != 200) _throwFromResponse(response);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['items'] as List<dynamic>).cast<Map<String, dynamic>>();
    });
  }

  static Future<void> saveCart(String email, List<CartItem> items) {
    return _wrapNetworkErrors(() async {
      final response = await http.put(
        Uri.parse("$baseUrl/cart/$email"),
        headers: _jsonHeaders,
        body: jsonEncode({"items": items.map((e) => e.toApiJson()).toList()}),
      );
      if (response.statusCode != 200) _throwFromResponse(response);
    });
  }
}
