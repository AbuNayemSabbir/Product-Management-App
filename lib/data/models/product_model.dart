class Product {
  final int? id;
  final int? tenantId;
  final String name;
  final String description;
  final bool isAvailable;

  Product({
    this.id,
    this.tenantId,
    required this.name,
    required this.description,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      tenantId: json['tenantId'],
      name: json['name'] ?? '', // Add null check
      description: json['description'] ?? '', // Add null check
      isAvailable: json['isAvailable'] ?? false, // Add null check
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  Product copyWith({
    int? id,
    int? tenantId,
    String? name,
    String? description,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}