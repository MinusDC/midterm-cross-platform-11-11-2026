import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/models/product_model.dart';

void main() {
  group('Product', () {
    test('maps Firestore data to a product', () {
      final product = Product.fromMap({
        'name': 'Bình giữ nhiệt',
        'price': 125000,
        'soluong': 12,
        'image': 'https://example.com/image.jpg',
      });

      expect(product.name, 'Bình giữ nhiệt');
      expect(product.price, 125000);
      expect(product.soluong, 12);
      expect(product.image, 'https://example.com/image.jpg');
    });

    test('serializes only the current product fields', () {
      final product = Product(
        name: '  Bình giữ nhiệt  ',
        price: 125000,
        soluong: 12,
        image: ' https://example.com/image.jpg ',
      );

      expect(product.toMap(), {
        'name': 'Bình giữ nhiệt',
        'price': 125000,
        'soluong': 12,
        'image': 'https://example.com/image.jpg',
      });
    });

    test('ignores legacy and unrelated fields', () {
      final product = Product.fromMap({
        'name': 'Ly sứ',
        'description': 'Đồ nhà bếp',
        'id': 'old-id',
        'category': 'Đồ gia dụng',
        'soluong': 4,
      });

      expect(product.toMap(), {
        'name': 'Ly sứ',
        'price': 0,
        'soluong': 4,
        'image': '',
      });
    });

    test('uses safe defaults for missing or invalid values', () {
      final product = Product.fromMap({
        'price': 'unknown',
        'soluong': 'unknown',
      });

      expect(product.name, isEmpty);
      expect(product.price, 0);
      expect(product.soluong, 0);
      expect(product.image, isEmpty);
    });
  });
}
