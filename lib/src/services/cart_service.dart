import 'package:dio/dio.dart';
import 'package:sneakerx/src/modules/cart/dtos/cart_response.dart';
import 'package:sneakerx/src/modules/cart/dtos/save_to_cart_request.dart';
import 'package:sneakerx/src/modules/cart/dtos/update_cart_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class CartService {
  static const String _cartPath = "/carts";

  Future<ApiResponse<CartResponse>> getCurrentUserCart() async {
    final endpoint = "$_cartPath/me";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => CartResponse.fromJson(data as Map<String, dynamic>)
      );

    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Get current user cart failed"
      );
    }
  }

  Future<ApiResponse<CartResponse>> updateCart(UpdateCartRequest request) async {
    final endpoint = "$_cartPath/me";

    try {
      print("REQUEST??? : ${request.toJson()}");
      final response = await ApiClient.put(endpoint,request.toJson());

      return ApiResponse.fromJson(
          response.data,
              (data) => CartResponse.fromJson(data as Map<String, dynamic>)
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update cart failed"
      );
    }
  }

  Future<ApiResponse<CartResponse>> saveToCart(SaveToCartRequest request) async {
    final endpoint = "$_cartPath/items";

    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      return ApiResponse.fromJson(
          response.data,
              (data) => CartResponse.fromJson(data as Map<String, dynamic>)
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Save to cart failed"
      );
    }
  }

  Future<ApiResponse<CartResponse>> deleteCartItem(int itemId) async {
    final endpoint = "$_cartPath/items/$itemId";

    try {
      final response = await ApiClient.delete(endpoint, null);

      return ApiResponse.fromJson(
          response.data,
              (data) => CartResponse.fromJson(data as Map<String, dynamic>)
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Delete item {$itemId} failed"
      );
    }
  }
}