class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'phone': phone, 'address': address, 'role': role,
  };
}
