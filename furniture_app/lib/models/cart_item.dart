class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  final int stock;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
    this.stock = 0,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'];
    return CartItem(
      productId: product is Map ? product['_id'] ?? '' : product ?? '',
      name: product is Map ? product['name'] ?? '' : '',
      price: (json['price'] ?? (product is Map ? product['price'] ?? 0 : 0)).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: product is Map && product['images'] != null && (product['images'] as List).isNotEmpty
          ? product['images'][0]['url'] ?? ''
          : '',
      stock: product is Map ? product['stock'] ?? 0 : 0,
    );
  }
}
