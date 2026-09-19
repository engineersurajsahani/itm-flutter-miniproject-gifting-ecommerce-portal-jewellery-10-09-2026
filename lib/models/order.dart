enum OrderStatus {
  ordered,
  shipped,
  outForDelivery,
  delivered,
}

OrderStatus orderStatusFromJson(String? value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.ordered,
  );
}

class OrderItem {
  final String? productId; // used only to let the backend decrement stock on creation
  final String productName;
  final String category;
  final double basePrice;
  final int quantity;
  final String packagingName;
  final double packagingPrice;
  final String? engravingText;
  final String? customGreetingMessage;
  final bool wrapInGoldFoil;
  final String imageUrl;
  final OrderStatus status;

  OrderItem({
    this.productId,
    required this.productName,
    required this.category,
    required this.basePrice,
    required this.quantity,
    required this.packagingName,
    required this.packagingPrice,
    this.engravingText,
    this.customGreetingMessage,
    required this.wrapInGoldFoil,
    required this.imageUrl,
    this.status = OrderStatus.ordered,
  });

  double get total => (basePrice * quantity) + packagingPrice + (wrapInGoldFoil ? 5.0 : 0.0);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      category: json['category'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      packagingName: json['packagingName'] as String,
      packagingPrice: (json['packagingPrice'] as num).toDouble(),
      engravingText: json['engravingText'] as String?,
      customGreetingMessage: json['customGreetingMessage'] as String?,
      wrapInGoldFoil: json['wrapInGoldFoil'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String,
      status: orderStatusFromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'basePrice': basePrice,
      'quantity': quantity,
      'packagingName': packagingName,
      'packagingPrice': packagingPrice,
      'engravingText': engravingText,
      'customGreetingMessage': customGreetingMessage,
      'wrapInGoldFoil': wrapInGoldFoil,
      'imageUrl': imageUrl,
      'status': status.name,
    };
  }
}

class OrderModel {
  final String? mongoId; // backend document id, used internally for status-update calls
  final String id; // friendly "ORD-xxxxx" code shown throughout the UI
  final String email; // owning consumer's account email
  final DateTime orderDate;
  final List<OrderItem> items;
  final double subtotal;
  final double giftCustomizationTotal;
  final double deliveryCharge;
  final double tax;
  final double grandTotal;

  // Shipping details
  final String fullName;
  final String addressLine1;
  final String city;
  final String postalCode;
  final String phone;

  // Vault code simulation for security check during shipping
  final String secureVaultCode;

  // How the order was paid for, e.g. "Credit Card •••• 1234".
  final String? paymentMethod;

  OrderStatus status;

  OrderModel({
    this.mongoId,
    required this.id,
    required this.email,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.giftCustomizationTotal,
    required this.deliveryCharge,
    required this.tax,
    required this.grandTotal,
    required this.fullName,
    required this.addressLine1,
    required this.city,
    required this.postalCode,
    required this.phone,
    required this.secureVaultCode,
    this.paymentMethod,
    this.status = OrderStatus.ordered,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      mongoId: json['mongoId'] as String?,
      id: json['orderId'] as String,
      email: json['email'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      giftCustomizationTotal: (json['giftCustomizationTotal'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      fullName: json['fullName'] as String,
      addressLine1: json['addressLine1'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      phone: json['phone'] as String,
      secureVaultCode: json['secureVaultCode'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      status: orderStatusFromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': id,
      'email': email,
      'orderDate': orderDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'giftCustomizationTotal': giftCustomizationTotal,
      'deliveryCharge': deliveryCharge,
      'tax': tax,
      'grandTotal': grandTotal,
      'fullName': fullName,
      'addressLine1': addressLine1,
      'city': city,
      'postalCode': postalCode,
      'phone': phone,
      'secureVaultCode': secureVaultCode,
      'paymentMethod': paymentMethod,
      'status': status.name,
    };
  }

  String get statusDisplay {
    switch (status) {
      case OrderStatus.ordered:
        return "Order Confirmed & Reserved";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.outForDelivery:
        return "Out for Delivery";
      case OrderStatus.delivered:
        return "Delivered";
    }
  }

  String get statusDescription {
    switch (status) {
      case OrderStatus.ordered:
        return "Your exquisite selection has been confirmed and reserved, and is being prepared for shipment.";
      case OrderStatus.shipped:
        return "Your order has left our vault and is on its way to you, under fully insured armored transit.";
      case OrderStatus.outForDelivery:
        return "Your order is out for delivery and will arrive at your doorstep shortly.";
      case OrderStatus.delivered:
        return "Your order has been successfully delivered and received under signature confirmation.";
    }
  }

  double get progressPercentage {
    switch (status) {
      case OrderStatus.ordered:
        return 0.2;
      case OrderStatus.shipped:
        return 0.55;
      case OrderStatus.outForDelivery:
        return 0.85;
      case OrderStatus.delivered:
        return 1.0;
    }
  }
}
