import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required this.firebaseService,
    required this.cloudinaryService,
  });

  final FirebaseService firebaseService;
  final CloudinaryService cloudinaryService;
  bool _isSaving = false;

  bool get isSaving => _isSaving;
  Stream<List<ProductDocument>> get products => firebaseService.watchProducts();

  Future<void> saveProduct({
    ProductDocument? existing,
    required String name,
    required double price,
    required int soluong,
    XFile? image,
  }) async {
    if (_isSaving) {
      throw StateError('Một thao tác lưu khác đang được thực hiện.');
    }
    if (existing == null && image == null) {
      throw ArgumentError('Vui lòng chọn ảnh cho sản phẩm mới.');
    }

    _isSaving = true;
    notifyListeners();
    try {
      final imageUrl = image == null
          ? existing!.product.image
          : await cloudinaryService.uploadImage(image);
      final product = Product(
        name: name,
        price: price,
        soluong: soluong,
        image: imageUrl,
      );

      if (existing == null) {
        await firebaseService.createProduct(product);
      } else {
        await firebaseService.updateProduct(existing.id, product);
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(ProductDocument product) =>
      firebaseService.deleteProduct(product.id);
}
