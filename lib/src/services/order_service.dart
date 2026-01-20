import 'package:dio/dio.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_order_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_order_response.dart';
import 'package:sneakerx/src/modules/seller_order/dtos/update_shop_order_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class OrderService {
  static const String _orderPath = "/orders";

  Future<ApiResponse<CreateOrderResponse>> createOrder(CreateOrderRequest request) async {
    final endpoint = "$_orderPath";

    print("CREATE ORDER REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      print("CREATE ORDER RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => CreateOrderResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Create order failed",
        data: null
      );
    }
  }

  Future<ApiResponse<ShopOrder>> updateShopOrder(UpdateShopOrderRequest request) async {
    final endpoint = "$_orderPath/shop-orders/${request.shopOrderId}";

    try {
      final response = await ApiClient.put(
          endpoint,
          request.toJson()
      );

      return ApiResponse.fromJson(
        response.data,
          (data) => ShopOrder.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Update shop order failed",
        data: null,
      );
    }
  }

  Future<ApiResponse<String>> deleteShopOrder(int shopOrderId) async {
    final endpoint = "$_orderPath//shop-orders/$shopOrderId";

    try {
      final response = await ApiClient.delete(
          endpoint,
          null
      );

      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
        data: response.data['data'],
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Delete order failed",
        data: null,
      );
    }
  }

}