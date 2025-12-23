import 'dart:io';

import 'package:sneakerx/src/modules/seller/models/update_variant_request.dart';

class UpdateProductRequest {
  final String name;
  final String description;
  final int shopId;
  final String status;
  final int categoryId;

  final List<String> keepImageUrls;
  final List<File> newImages;
  final List<VariantUpdateDto> variants;

  UpdateProductRequest({
    required this.name,
    required this.description,
    required this.shopId,
    required this.status,
    required this.categoryId,
    required this.newImages,
    required this.keepImageUrls,
    required this.variants
  });
}