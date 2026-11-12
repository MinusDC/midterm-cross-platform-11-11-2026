import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductDocument {
  const ProductDocument({required this.id, required this.product});

  final String id;
  final Product product;
}

class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
    : _products = (firestore ?? FirebaseFirestore.instance).collection(
        'products',
      );

  final CollectionReference<Map<String, dynamic>> _products;

  Stream<List<ProductDocument>> watchProducts() => _products.snapshots().map(
    (snapshot) => snapshot.docs
        .map(
          (document) => ProductDocument(
            id: document.id,
            product: Product.fromMap(document.data()),
          ),
        )
        .toList(growable: false),
  );

  Future<void> createProduct(Product product) async {
    await _products.add(product.toMap());
  }

  Future<void> updateProduct(String id, Product product) async {
    await _products.doc(id).set(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
