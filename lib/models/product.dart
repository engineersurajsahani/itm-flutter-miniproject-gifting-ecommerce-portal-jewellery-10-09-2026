class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String metalType; // e.g. "18K Gold", "950 Platinum"
  final String gemstone;  // e.g. "Natural Emerald", "VVS1 Diamond"
  final double weight;    // in grams
  final String collection; // e.g. "The Royal Emerald", "Celestial Shine"
  int stock;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.metalType,
    required this.gemstone,
    required this.weight,
    required this.collection,
    required this.stock,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: (json['reviewsCount'] as num).toInt(),
      metalType: json['metalType'] as String,
      gemstone: json['gemstone'] as String,
      weight: (json['weight'] as num).toDouble(),
      collection: json['collection'] as String,
      stock: (json['stock'] as num).toInt(),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'metalType': metalType,
      'gemstone': gemstone,
      'weight': weight,
      'collection': collection,
      'stock': stock,
      'isFeatured': isFeatured,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewsCount,
    String? metalType,
    String? gemstone,
    double? weight,
    String? collection,
    int? stock,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      metalType: metalType ?? this.metalType,
      gemstone: gemstone ?? this.gemstone,
      weight: weight ?? this.weight,
      collection: collection ?? this.collection,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
