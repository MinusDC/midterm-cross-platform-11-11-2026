class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    final rawPrice = map['price'];
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      category:
          map['category'] as String? ?? map['description'] as String? ?? '',
      price: rawPrice is num ? rawPrice.toDouble() : 0,
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'category': category.trim(),
    'price': price,
    'imageUrl': imageUrl,
  };
}
