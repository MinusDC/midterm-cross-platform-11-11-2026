import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/models/product_model.dart';

void main() {
  group('Product', () {
    test('maps Firestore data to a product', () {
      final product = Product.fromMap('product-1', {
        'name': 'Bình giữ nhiệt',
        'category': 'Đồ gia dụng',
        'price': 125000,
        'imageUrl': 'https://example.com/image.jpg',
      });

      expect(product.id, 'product-1');
      expect(product.name, 'Bình giữ nhiệt');
      expect(product.category, 'Đồ gia dụng');
      expect(product.price, 125000);
      expect(product.imageUrl, 'https://example.com/image.jpg');
    });

    test('serializes only the current product fields', () {
      final product = Product(
        id: 'product-1',
        name: '  Bình giữ nhiệt  ',
        category: '  Đồ gia dụng  ',
        price: 125000,
        imageUrl: 'https://example.com/image.jpg',
      );

      final map = product.toMap();
      expect(map, {
        'name': 'Bình giữ nhiệt',
        'category': 'Đồ gia dụng',
        'price': 125000,
        'imageUrl': 'https://example.com/image.jpg',
      });
      expect(map.containsKey('description'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('updatedAt'), isFalse);
    });

    test('reads a legacy description as category', () {
      final product = Product.fromMap('product-2', {
        'name': 'Ly sứ',
        'description': 'Đồ nhà bếp',
      });

      expect(product.category, 'Đồ nhà bếp');
    });

    test('uses safe defaults for missing or invalid values', () {
      final product = Product.fromMap('product-3', {'price': 'unknown'});

      expect(product.name, isEmpty);
      expect(product.category, isEmpty);
      expect(product.price, 0);
      expect(product.imageUrl, isEmpty);
    });
  });
}
