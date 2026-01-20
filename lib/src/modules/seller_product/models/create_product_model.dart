import 'package:sneakerx/src/modules/seller_product/models/create_attribute_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_sku_request.dart';


class CreateProductRequest {
  final String name;
  final String description;
  final int shopId;
  final int categoryId;
  final double basePrice;

  final List<String> imageUrls;
  final List<CreateAttributeRequest> attributes;
  final List<CreateSkuRequest> skus;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.shopId,
    required this.categoryId,
    required this.basePrice,
    required this.imageUrls,
    required this.attributes,
    required this.skus,
  });

  Map<String, dynamic> toJson() {
    return {
      'name' : name,
      'description' : description,
      'shopId' : shopId,
      'categoryId' : categoryId,
      'basePrice' : basePrice,
      'imageUrls' : imageUrls,
      'attributes' : attributes.map((attr) => attr.toJson()).toList(),
      'skus' : skus.map((sku) => sku.toJson()).toList(),
    };
  }

}