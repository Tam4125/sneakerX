import 'dart:io';

import 'package:sneakerx/src/modules/seller/models/create_variant_model.dart';

class CreateProductRequest {
  final String name;
  final String description;
  final int shopId;
  final String status;
  final int categoryId;

  final List<File> images;
  final List<CreateVariantRequest> variants;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.shopId,
    required this.status,
    required this.categoryId,
    required this.images,
    required this.variants
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name' : name,
  //     'description' : description,
  //     'shopId' : shopId,
  //     'status' : status,
  //     'categoryId' : categoryId,
  //     'images' : images,
  //   };
  // }

}