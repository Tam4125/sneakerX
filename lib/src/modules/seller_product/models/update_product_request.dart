import 'package:sneakerx/src/modules/seller_product/models/create_attribute_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_attribute_value_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_sku_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/update_sku_request.dart';

class UpdateProductRequest {
  final int productId;
  final String name;
  final String description;
  final int shopId;
  final int categoryId;
  final double basePrice;

  final List<int> keepImages;
  final List<String> newImageUrls;

  final Map<int, List<int>> keepAttributesKeepValues;
  final Map<int, List<CreateAttributeValueRequest>> keepAttributesNewValues;
  final List<CreateAttributeRequest> newAttributes;

  final List<UpdateSkuRequest> existingSkus;
  final List<CreateSkuRequest> newSkus;

  UpdateProductRequest({
    required this.name,
    required this.description,
    required this.shopId,
    required this.productId,
    required this.basePrice,
    required this.categoryId,
    required this.keepImages,
    required this.newImageUrls,
    required this.keepAttributesKeepValues,
    required this.keepAttributesNewValues,
    required this.newAttributes,
    required this.existingSkus,
    required this.newSkus
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'shopId': shopId,
      'productId': productId,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'keepImages': keepImages,
      'newImageUrls': newImageUrls,
      'keepAttributesKeepValues': keepAttributesKeepValues.map((key, val) => MapEntry(key.toString(), val)),
      'keepAttributesNewValues': keepAttributesNewValues.map((key, val) => MapEntry(key.toString(), val.map((ele) => ele.toJson()).toList())),
      'newAttributes': newAttributes.map((ele) => ele.toJson()).toList(),
      'existingSkus': existingSkus.map((ele) => ele.toJson()).toList(),
      'newSkus': newSkus.map((ele) => ele.toJson()).toList(),
    };
  }
}