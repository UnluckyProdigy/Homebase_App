import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';

class BarcodeProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? description;

  BarcodeProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.description,
  });
}

class BarcodeApiService {
  final Dio _dio;

  BarcodeApiService() : _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    final result = await _tryOpenFoodFacts(barcode);
    if (result != null) return result;
    return _tryUpcItemDb(barcode);
  }

  Future<BarcodeProduct?> _tryOpenFoodFacts(String barcode) async {
    try {
      final response = await _dio.get(
        '${AppConstants.openFoodFactsBaseUrl}/$barcode',
        queryParameters: {
          'fields': 'product_name,brands,image_url,generic_name',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final name = product['product_name'] as String?;
          if (name != null && name.isNotEmpty) {
            return BarcodeProduct(
              barcode: barcode,
              name: name,
              brand: product['brands'] as String?,
              imageUrl: product['image_url'] as String?,
              description: product['generic_name'] as String?,
            );
          }
        }
      }
    } on DioException {
      // Network error, fall through to next API
    }
    return null;
  }

  Future<BarcodeProduct?> _tryUpcItemDb(String barcode) async {
    try {
      final response = await _dio.get(
        AppConstants.upcItemDbBaseUrl,
        queryParameters: {'upc': barcode},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final item = items[0];
          final title = item['title'] as String?;
          if (title != null && title.isNotEmpty) {
            final images = item['images'] as List?;
            return BarcodeProduct(
              barcode: barcode,
              name: title,
              brand: item['brand'] as String?,
              imageUrl:
                  (images != null && images.isNotEmpty) ? images[0] as String? : null,
              description: item['description'] as String?,
            );
          }
        }
      }
    } on DioException {
      // Network error or rate limited
    }
    return null;
  }
}
