import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  CloudinaryService({required String cloudName, required String uploadPreset})
    : _cloudName = cloudName.trim(),
      _uploadPreset = uploadPreset.trim();

  factory CloudinaryService.fromDotEnv() => CloudinaryService(
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
  );

  final String _cloudName;
  final String _uploadPreset;

  Future<String> uploadImage(XFile image) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw const CloudinaryException(
        'Thiếu CLOUDINARY_CLOUD_NAME hoặc CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final endpoint = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$_cloudName/image/upload',
    );
    final imageBytes = await image.readAsBytes();
    if (imageBytes.isEmpty) {
      throw const CloudinaryException('Tệp ảnh được chọn không có dữ liệu.');
    }
    final request = http.MultipartRequest('POST', endpoint)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: image.name),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw CloudinaryException(
        'Cloudinary trả về phản hồi không hợp lệ (HTTP ${response.statusCode}).',
      );
    } on TypeError {
      throw const CloudinaryException(
        'Cloudinary trả về dữ liệu không đúng định dạng.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload['error'];
      final rawMessage = error is Map<String, dynamic>
          ? error['message']
          : null;
      final message = rawMessage is String ? rawMessage : null;
      throw CloudinaryException(
        message ?? 'Tải ảnh thất bại (HTTP ${response.statusCode}).',
      );
    }

    final secureUrl = payload['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw const CloudinaryException(
        'Phản hồi Cloudinary không có secure_url.',
      );
    }
    return secureUrl;
  }
}

class CloudinaryException implements Exception {
  const CloudinaryException(this.message);

  final String message;

  @override
  String toString() => message;
}
