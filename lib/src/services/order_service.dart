import 'dart:convert';
import 'dart:ffi';

import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_order_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/update_order_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class OrderService {
  static const String baseUrl = "http://10.0.2.2:8080/orders";

  Future<Order?> createOrder(CreateOrderRequest request) async {
    final url = "$baseUrl";

    try {
      final response = await ApiClient.post(
        url,
        request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse<Order>.fromJson(
          jsonMap,
              (data) => Order.fromJson(data as Map<String, dynamic>),
        );
        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error create new order");
      }

    } catch (e) {
      throw Exception("Error create new order: $e");
    }
  }

  Future<Order?> updateOrderStatus(UpdateOrderStatusRequest request) async {
    String url = "$baseUrl/${request.orderId}/status";
    try {
      final response = await ApiClient.put(
          url,
          request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Order>.fromJson(
            jsonMap,
                (data) => Order.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error update order status");
      }
    } catch (e) {
      throw Exception("Error update order status: $e");
    }
  }

  Future<String?> deleteOrder(int orderId) async {
    String url = "$baseUrl/$orderId";

    try {
      final response = await ApiClient.delete(
          url,
          null
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        final data = jsonMap['data'];
        return data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error delete order");
      }
    } catch (e) {
      throw Exception("Error delete order: $e");
    }

  }

  Future<Order?> getOrderDetail(int orderId) async {
    String url = "$baseUrl/$orderId";

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {

        Map<String, dynamic> jsonMap = jsonDecode(response.body);


        final order = jsonMap['data'];
        return Order.fromJson(order);

      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Failed order detail");
      }
    } catch (e) {
      throw Exception("Failed order detail: $e");
    }

  }

}