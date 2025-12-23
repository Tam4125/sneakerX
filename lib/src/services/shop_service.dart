import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:http/http.dart' as http;
import 'package:sneakerx/src/modules/seller/models/create_product_model.dart';
import 'package:sneakerx/src/modules/seller/models/update_product_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';


class ShopService {
  static const String baseUrl = "http://10.0.2.2:8080/shops";

  Future<Shop?> getCurrentUserShop() async {
    final url = "$baseUrl/me";

    try {
      final response = await ApiClient.get(url);

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse<Shop>.fromJson(
          jsonMap,
              (data) => Shop.fromJson(data as Map<String, dynamic>),
        );
        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error get current user cart");
      }

    } catch (e) {
      throw Exception("Error fetching current shop: $e");
    }
  }

  Future<Shop?> getShopDetail(int shopId) async {
    final url = Uri.parse("$baseUrl/$shopId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Shop>.fromJson(
            jsonMap,
                (data) => Shop.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Failed fetch shop detail");
      }
    } catch (e) {
      throw Exception("Error fetching shop: $e");
    }
  }

  Future<Product?> createProduct(CreateProductRequest request) async {
    final url = "$baseUrl/product";

    // 1. Prepare Fields Map
    final fields = <String, String>{
      'shopId': request.shopId.toString(),
      'name': request.name,
      'description': request.description,
      'status': request.status,
      'categoryId': request.categoryId.toString(),
    };

    final variants = request.variants;
    // 2. Add Complex List Fields (Spring Boot @ModelAttribute style)
    for (int i = 0; i < variants.length; i++) {
      fields['variants[$i].variantType'] = variants[i].variantType;
      fields['variants[$i].variantValue'] = variants[i].variantValue;
      fields['variants[$i].price'] = variants[i].price.toString();
      fields['variants[$i].stock'] = variants[i].stock.toString();
    }

    try {
      final response = await ApiClient.postMultipart(
        url: url,
        fields: fields,
        files: request.images ?? [],
        fileField: 'images'
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Product>.fromJson(
            jsonMap,
                (data) => Product.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        // Parse error message from backend if available
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Failed to add product");
      }
    } catch (e) {
      throw Exception("Service error: $e");
    }
  }


  Future<ApiResponse<Product>> updateProduct(int productId, UpdateProductRequest request) async {
    final url = "$baseUrl/product/$productId";
    // 1. Prepare Fields Map
    Map<String, String> fields = {
      'shopId': request.shopId.toString(),
      'name': request.name,
      'description': request.description,
      'status': request.status,
      'categoryId': request.categoryId.toString(),
    };

    final variants = request.variants;
    // 2. Add Complex List Fields (Spring Boot @ModelAttribute style)
    for (int i = 0; i < variants.length; i++) {
      if(variants[i].variantId != null) {
        fields['variants[$i].variantId'] = variants[i].variantId.toString();
      }
      fields['variants[$i].variantType'] = variants[i].variantType;
      fields['variants[$i].variantValue'] = variants[i].variantValue;
      fields['variants[$i].price'] = variants[i].price.toString();
      fields['variants[$i].stock'] = variants[i].stock.toString();
    }

    for (int i = 0; i < request.keepImageUrls.length; i++) {
      fields['keepImageUrls[$i]'] = request.keepImageUrls[i];
    }

    try {
      final response = await ApiClient.putMultipart(
        url: url,
        fields: fields,
        files: request.newImages,
        fileField: "newImages"
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if(response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Product>.fromJson(
          jsonMap,
            (data) => Product.fromJson(data as Map<String, dynamic>)
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Update product service error: $e");
    }
  }


}