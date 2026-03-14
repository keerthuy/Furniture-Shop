class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String deliveryAddress;
  final String phone;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.phone,
    this.paymentMethod = 'COD',
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['_id'] ?? '' : json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ?? [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      phone: json['phone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] is Map ? json['productId']['_id'] ?? '' : json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
    );
  }
}
