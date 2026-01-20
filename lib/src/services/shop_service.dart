import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/product_detail/dtos/product_detail_response.dart';
import 'package:sneakerx/src/modules/seller_dashboard/models/shop_detail.dart';
import 'package:sneakerx/src/modules/seller_info/dtos/update_shop_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_product_model.dart';
import 'package:sneakerx/src/modules/seller_product/models/update_product_request.dart';
import 'package:sneakerx/src/modules/seller_signup/dtos/create_shop_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';


class ShopService {
  static const String _shopPath = "/shops";

  Future<ApiResponse<ShopDetailResponse>> getCurrentUserShop() async {
    final url = "$_shopPath/me";

    try {
      final response = await ApiClient.get(url);
      return ApiResponse.fromJson(
        response.data,
          (data) => ShopDetailResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Get current user shop failed",
        data: null
      );
    }
  }

  Future<ApiResponse<ShopDetailResponse>> getShopById(int shopId) async {
    final url = "$_shopPath/$shopId";

    try {
      final response = await ApiClient.get(url);
      return ApiResponse.fromJson(
          response.data,
              (data) => ShopDetailResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get shop Id {$shopId} failed",
          data: null
      );
    }
  }

  Future<ApiResponse<List<ShopOrder>>> getShopOrders() async {
    final endpoint = "$_shopPath/me/orders";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => (data as List?)
            ?.map((ele) => ShopOrder.fromJson(ele as Map<String, dynamic>))
            .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get shop orders failed",
          data: null
      );
    }
  }

  Future<ApiResponse<Shop>> createShop(CreateShopRequest request) async {
    final endpoint = "$_shopPath";

    print("CREATE SHOP REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      print("CREATE SHOP RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => Shop.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Create shop failed",
        data: null
      );
    }
  }

  Future<ApiResponse<Shop>> updateShop(UpdateShopRequest request) async {
    final endpoint = "$_shopPath/${request.shopId}";
    print("UPDATE SHOP REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.put(
          endpoint,
          request.toJson()
      );
      print("UPDATE SHOP RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
          response.data,
              (data) => Shop.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update shop failed",
          data: null
      );
    }
  }

  Future<ApiResponse<ProductDetailResponse>> createProduct(CreateProductRequest request) async {
    final endpoint = "$_shopPath/products";
    print("CREATE PRODUCT REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.post(
          endpoint,
          request.toJson()
      );
      print("CREATE PRODUCT RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
          response.data,
              (data) => ProductDetailResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Create product failed",
          data: null
      );
    }
  }

  Future<ApiResponse<ProductDetailResponse>> updateProduct(UpdateProductRequest request) async {
    final endpoint = "$_shopPath/products/${request.productId}";
    print("UPDATE PRODUCT REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.put(
          endpoint,
          request.toJson()
      );
      print("UPDATE PRODUCT RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
          response.data,
              (data) => ProductDetailResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update product failed",
          data: null
      );
    }
  }

  //
  // Future<List<OrderItem>?> getShopOrderItems(int shopId) async {
  //   String url = "$baseUrl/$shopId/orderItems";
  //
  //   try {
  //     final response = await ApiClient.get(url);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Map<String, dynamic> jsonMap = jsonDecode(response.body);
  //
  //       if(response.body.isEmpty) return [];
  //       final List orderItemList = jsonMap['data'] ?? [];
  //       final orderItems =  orderItemList.map((order) {
  //         return OrderItem.fromJson(order as Map<String, dynamic>);
  //       }).toList();
  //
  //       return orderItems;
  //     } else {
  //       final errorMap = jsonDecode(response.body);
  //       throw Exception(errorMap['message'] ?? "Failed get shop orders");
  //     }
  //   } catch (e) {
  //     throw Exception("Failed get shop orders: $e");
  //   }
  // }
  //
  // Future<List<Order>?> getShopOrders(int shopId) async {
  //   String url = "$baseUrl/$shopId/orders";
  //
  //   try {
  //     final response = await ApiClient.get(url);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Map<String, dynamic> jsonMap = jsonDecode(response.body);
  //
  //       if(response.body.isEmpty) return [];
  //       final List orderList = jsonMap['data'] ?? [];
  //       final orders =  orderList.map((order) {
  //         return Order.fromJson(order as Map<String, dynamic>);
  //       }).toList();
  //
  //       return orders;
  //     } else {
  //       final errorMap = jsonDecode(response.body);
  //       throw Exception(errorMap['message'] ?? "Failed get shop orders");
  //     }
  //   } catch (e) {
  //     throw Exception("Failed get shop orders: $e");
  //   }
  // }

}