class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<ProductImage> images;
  final String category;
  final int stock;
  final String sellerId;
  final String sellerName;
  final double ratings;
  final int numReviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.stock,
    required this.sellerId,
    this.sellerName = '',
    this.ratings = 0,
    this.numReviews = 0,
  });

  String get imageUrl =>
      images.isNotEmpty ? images.first.url : '';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      sellerId: json['sellerId'] is Map
          ? json['sellerId']['_id'] ?? ''
          : json['sellerId'] ?? '',
      sellerName: json['sellerId'] is Map
          ? json['sellerId']['name'] ?? ''
          : '',
      ratings: (json['ratings'] ?? 0).toDouble(),
      numReviews: json['numReviews'] ?? 0,
    );
  }
}

class ProductImage {
  final String publicId;
  final String url;

  ProductImage({required this.publicId, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
