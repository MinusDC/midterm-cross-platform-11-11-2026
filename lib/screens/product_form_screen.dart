import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../services/firebase_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({this.document, super.key});

  final ProductDocument? document;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    final product = widget.document?.product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(0);
      _quantityController.text = product.soluong.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProductProvider>().isSaving;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _ImagePickerField(
                    selectedImageBytes: _selectedImageBytes,
                    existingImageUrl: widget.document?.product.image,
                    isSaving: isSaving,
                    onTap: isSaving ? null : _pickImage,
                  ),
                  if (!_isEditing && _selectedImage == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng chọn ảnh cho sản phẩm mới.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isSaving,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                      hintText: 'Ví dụ: Bình giữ nhiệt',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập tên sản phẩm.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    enabled: !isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Giá (₫)',
                      hintText: 'Ví dụ: 250000',
                      prefixIcon: Icon(Icons.payment_outlined),
                    ),
                    validator: (value) {
                      final price = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );
                      if (price == null || !price.isFinite || price <= 0) {
                        return 'Nhập mức giá lớn hơn 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      hintText: 'Ví dụ: 10',
                      prefixIcon: Icon(Icons.inventory_outlined),
                    ),
                    validator: (value) {
                      final quantity = int.tryParse((value ?? '').trim());
                      if (quantity == null || quantity < 0) {
                        return 'Nhập số lượng là số nguyên không âm.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: isSaving ? null : _save,
                    icon: isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      isSaving ? 'Đang tải ảnh và lưu...' : 'Lưu sản phẩm',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 88,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $error')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh sản phẩm.')),
      );
      return;
    }

    final price = double.parse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    final quantity = int.parse(_quantityController.text.trim());
    try {
      await context.read<ProductProvider>().saveProduct(
        existing: widget.document,
        name: _nameController.text,
        price: price,
        soluong: quantity,
        image: _selectedImage,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Đã cập nhật sản phẩm.' : 'Đã thêm sản phẩm.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu sản phẩm: $error')),
        );
      }
    }
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.selectedImageBytes,
    required this.existingImageUrl,
    required this.isSaving,
    required this.onTap,
  });

  final Uint8List? selectedImageBytes;
  final String? existingImageUrl;
  final bool isSaving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7DF)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (selectedImageBytes != null)
            Image.memory(selectedImageBytes!, fit: BoxFit.cover)
          else if (existingImageUrl != null && existingImageUrl!.isNotEmpty)
            Image.network(
              existingImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const _ImageHint(),
            )
          else
            const _ImageHint(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.black.withValues(alpha: 0.55),
              child: Text(
                isSaving
                    ? 'Đang tải ảnh lên...'
                    : 'Chạm để chọn ảnh từ thư viện',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ImageHint extends StatelessWidget {
  const _ImageHint();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_outlined,
        size: 46,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 8),
      const Text('Chọn ảnh sản phẩm'),
    ],
  );
}
