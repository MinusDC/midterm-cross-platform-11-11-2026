class Product {
  const Product({
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  final String name;
  final double price;
  final int soluong;
  final String image;

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final rawQuantity = map['soluong'];
    final rawName = map['name'];
    final rawImage = map['image'];
    return Product(
      name: rawName is String ? rawName : '',
      price: rawPrice is num ? rawPrice.toDouble() : 0,
      soluong: rawQuantity is num ? rawQuantity.toInt() : 0,
      image: rawImage is String ? rawImage : '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'price': price,
    'soluong': soluong,
    'image': image.trim(),
  };
}
