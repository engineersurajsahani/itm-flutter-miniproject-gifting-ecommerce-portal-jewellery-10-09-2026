import 'product.dart';

enum GiftPackaging {
  none,
  standard, // Cream Linen Box - $0
  celestialBox, // Golden-Embossed Forest Wood Box - $15
  velvetCase, // Imperial Royal Velvet Vault - $25
}

GiftPackaging giftPackagingFromJson(String? value) {
  return GiftPackaging.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GiftPackaging.none,
  );
}

class CartItem {
  final Product product;
  int quantity;
  GiftPackaging giftPackaging;
  String? engravingText; // E.g., custom initials on the inside band
  String? customGreetingMessage; // Text written on custom calligraphy card with wax seal
  bool wrapInGoldFoil; // Wrap the packaging using a luxurious silk ribbon and golden envelope

  CartItem({
    required this.product,
    this.quantity = 1,
    this.giftPackaging = GiftPackaging.none,
    this.engravingText,
    this.customGreetingMessage,
    this.wrapInGoldFoil = false,
  });

  double get packagingPrice {
    switch (giftPackaging) {
      case GiftPackaging.none:
        return 0.0;
      case GiftPackaging.standard:
        return 10.0; // Premium Standard Linen
      case GiftPackaging.celestialBox:
        return 20.0; // Handcrafted Cedarwood Box
      case GiftPackaging.velvetCase:
        return 35.0; // Royal Velvet Case
    }
  }

  String get packagingName {
    switch (giftPackaging) {
      case GiftPackaging.none:
        return "None";
      case GiftPackaging.standard:
        return "Signature Cream Linen Envelope & Box";
      case GiftPackaging.celestialBox:
        return "Imperial Forest Emerald Cedarwood Box";
      case GiftPackaging.velvetCase:
        return "Royal Silk-Lined Emerald Velvet Vault";
    }
  }

  double get itemTotal {
    double base = product.price * quantity;
    if (giftPackaging != GiftPackaging.none) {
      base += packagingPrice;
    }
    if (wrapInGoldFoil) {
      base += 5.0; // Gold sealing ribbon
    }
    return base;
  }

  // Raw shape synced with the backend's cart document: only a reference to
  // the product plus customization, not the full product payload.
  Map<String, dynamic> toApiJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'giftPackaging': giftPackaging.name,
      'engravingText': engravingText,
      'customGreetingMessage': customGreetingMessage,
      'wrapInGoldFoil': wrapInGoldFoil,
    };
  }

  // Resolves a raw backend cart entry against the already-loaded product
  // catalog. Returns null if the referenced product no longer exists
  // (e.g. deleted by admin since the item was added).
  static CartItem? fromApiJson(Map<String, dynamic> json, List<Product> catalog) {
    Product? product;
    for (final p in catalog) {
      if (p.id == json['productId']) {
        product = p;
        break;
      }
    }
    if (product == null) return null;

    return CartItem(
      product: product,
      quantity: (json['quantity'] as num).toInt(),
      giftPackaging: giftPackagingFromJson(json['giftPackaging'] as String?),
      engravingText: json['engravingText'] as String?,
      customGreetingMessage: json['customGreetingMessage'] as String?,
      wrapInGoldFoil: json['wrapInGoldFoil'] as bool? ?? false,
    );
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    GiftPackaging? giftPackaging,
    String? engravingText,
    String? customGreetingMessage,
    bool? wrapInGoldFoil,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      giftPackaging: giftPackaging ?? this.giftPackaging,
      engravingText: engravingText ?? this.engravingText,
      customGreetingMessage: customGreetingMessage ?? this.customGreetingMessage,
      wrapInGoldFoil: wrapInGoldFoil ?? this.wrapInGoldFoil,
    );
  }
}
