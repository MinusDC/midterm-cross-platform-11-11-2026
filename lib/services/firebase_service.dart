import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
    : _products = (firestore ?? FirebaseFirestore.instance).collection(
        'products',
      );

  final CollectionReference<Map<String, dynamic>> _products;

  Stream<List<Product>> watchProducts() => _products.snapshots().map(
    (snapshot) => snapshot.docs
        .map((document) => Product.fromMap(document.id, document.data()))
        .toList(growable: false),
  );

  Future<void> createProduct(Product product) async {
    await _products.add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update({
      ...product.toMap(),
      'description': FieldValue.delete(),
      'createdAt': FieldValue.delete(),
      'updatedAt': FieldValue.delete(),
    });
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
