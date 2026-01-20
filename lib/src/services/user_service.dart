import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/user.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_user_address_request.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_address_request.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_user_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class UserService {
  static const String _userPath = "/users";

  Future<ApiResponse<User>> getCurrentUser() async {
    final endpoint = "$_userPath/me";
    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => User.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch (e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get current user failed",
          data: null
      );
    }
  }

  Future<ApiResponse<User>> updateUserDetail(UpdateUserRequest request) async {
    final endpoint = "$_userPath/me";

    print("UPDATE USER REQUEST???: ${request.toJson()}");
    try {
      final response = await ApiClient.put(
        endpoint,
        request.toJson()
      );

      print("UPDATE USER RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => User.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch (e) {

      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update user failed",
          data: null
      );
    }
  }

  Future<ApiResponse<List<UserAddress>>> getAddresses() async {
    final endpoint = "$_userPath/addresses";
    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => (data as List<dynamic>?)
              ?.map((ele) => UserAddress.fromJson(ele as Map<String, dynamic>))
              .toList() ?? []
      );
    } on DioException catch (e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get current user addresses failed",
          data: null
      );
    }
  }

  Future<ApiResponse<UserAddress>> createAddress(CreateUserAddressRequest request) async {
    final endpoint = "$_userPath/addresses";
    print("CREATE USER ADDRESS REQUEST???: ${request.toJson()}");
    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );
      return ApiResponse.fromJson(
        response.data,
          (data) => UserAddress.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Create user address failed",
          data: null
      );
    }
  }

  Future<ApiResponse<UserAddress>> updateAddress(UpdateAddressRequest request) async {
    final endpoint = "$_userPath/addresses/${request.addressId}";
    print("UPDATE USER ADDRESS REQUEST???: ${request.toJson()}");

    try {
      final response = await ApiClient.put(
        endpoint,
        request.toJson()
      );

      return ApiResponse.fromJson(
        response.data,
          (data) => UserAddress.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update user address failed",
          data: null
      );
    }
  }

  Future<ApiResponse<String>> deleteAddress(int addressId) async {
    final endpoint = "$_userPath/addresses/$addressId";

    try {
      final response = await ApiClient.delete(
        endpoint,
        null
      );

      return ApiResponse(
        success: true,
        message: response.data['message'],
        data: response.data['data']
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Delete user address failed",
        data: null
      );
    }
  }

  Future<ApiResponse<List<Order>>> getOrders() async {
    String url = "$_userPath/orders";
    try {
      final response = await ApiClient.get(url);

      print("GET USER ORDERS RESPONSE???: ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => (data as List?)
            ?.map((ele) => Order.fromJson(ele as Map<String, dynamic>))
          .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Get current user orders failed",
        data: null
      );
    }
  }

}