import 'dart:convert';

import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/cart.dart';
import 'package:sneakerx/src/modules/cart/dtos/save_to_cart_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class CartService {
  static const String baseUrl = "${AppConfig.baseUrl}/carts";

  Future<Cart?> getCurrentUserCart() async {
    final url = "$baseUrl/me";

    try {
      final response = await ApiClient.get(url);

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Cart>.fromJson(
            jsonMap,
                (data) => Cart.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error get current user cart");
      }
    } catch (e) {
      throw Exception("Error get current user cart: $e}");
    }
  }

  Future<Cart?> saveToCart(SaveToCartRequest request) async {
    final url = "$baseUrl/items";

    try {
      final response = await ApiClient.post(
        url,
        request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Cart>.fromJson(
            jsonMap,
                (data) => Cart.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error save product to cart");
      }
    } catch (e) {
      throw Exception("Error save product to cart: $e}");
    }
  }

  Future<Cart?> deleteCartItem(int itemId) async {
    final url = "$baseUrl/items/$itemId";

    try {
      final response = await ApiClient.delete(url, null);

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Cart>.fromJson(
            jsonMap,
                (data) => Cart.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error delete cart item");
      }
    } catch (e) {
      throw Exception("Error delete cart item: $e}");
    }
  }
}