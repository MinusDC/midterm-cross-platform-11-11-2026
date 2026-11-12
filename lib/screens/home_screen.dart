import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsStream = context.read<ProductProvider>().products;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sản phẩm'),
            Text(
              'Quản lý kho hàng của bạn',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm mới'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ProductDocument>>(
        stream: productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => _refresh(context),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Đang tải sản phẩm...');
          }
          final products = snapshot.data ?? const <ProductDocument>[];
          if (products.isEmpty) {
            return const _EmptyView();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = switch (constraints.maxWidth) {
                >= 1000 => 4,
                >= 680 => 3,
                >= 440 => 2,
                _ => 1,
              };
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: columns == 1 ? 0.9 : 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final document = products[index];
                  return ProductCard(
                    product: document.product,
                    onEdit: () => _openForm(context, document: document),
                    onDelete: () => _confirmDelete(context, document),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        tooltip: 'Thêm sản phẩm',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, {ProductDocument? document}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormScreen(document: document),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductDocument document,
  ) async {
    final product = document.product;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn có chắc muốn xóa "${product.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<ProductProvider>().deleteProduct(document);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa sản phẩm: $error')),
        );
      }
    }
  }

  void _refresh(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await context.read<AuthService>().signOut();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể đăng xuất: $error')));
      }
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Thêm sản phẩm đầu tiên để bắt đầu quản lý kho hàng.'),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text('Không thể tải sản phẩm: $message', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
