import 'dart:convert';

import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_user_address_request.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_address_request.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class UserService {
  static const String baseUrl = "http://10.0.2.2:8080/users";

  Future<ApiResponse<UserSignInResponse>> getCurrentUser() async {
    String url = "$baseUrl/me";
    try {
      final response = await ApiClient.get(url);
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<UserSignInResponse>.fromJson(
          jsonMap,
              (data) => UserSignInResponse.fromJson(data as Map<String, dynamic>),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(response.body);

        return ApiResponse<UserSignInResponse>(
            success: errorMap['success'] ?? false,
            message: errorMap['message'] ?? "Sign in failed",
            data: errorMap['data']
        );
      }
    } catch (e) {
      throw Exception("Get current user failed: $e");
    }
  }

  Future<List<Order>?> getOrders() async {
    String url = "$baseUrl/orders";
    try {
      final response = await ApiClient.get(url);
      if (response.body.isEmpty) return [];
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List orderList = jsonMap['data'] ?? [];
        final orders =  orderList.map((order) {

          // Safe casting ensures we don't crash if an item isn't a Map
          return Order.fromJson(order as Map<String, dynamic>);
        }).toList();

        return orders;
      } else {
        throw Exception("Get current user orders failed: ${jsonMap['message']}");
      }
    } catch (e) {
      throw Exception("Get current user orders failed: $e");
    }
  }

  Future<List<UserAddress>?> getAddresses() async {
    String url = "$baseUrl/addresses";
    try {
      final response = await ApiClient.get(url);
      if (response.body.isEmpty) return [];
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List addressList = jsonMap['data'] ?? [];
        final addresses =  addressList.map((address) {

          // Safe casting ensures we don't crash if an item isn't a Map
          return UserAddress.fromJson(address as Map<String, dynamic>);
        }).toList();

        return addresses;
      } else {
        throw Exception("Get current user addresses failed: ${jsonMap['message']}");
      }
    } catch (e) {
      throw Exception("Get current user addresses failed: $e");
    }
  }

  Future<UserAddress?> createAddress(CreateUserAddressRequest request) async {
    String url = "$baseUrl/addresses";
    try {
      final response = await ApiClient.post(
        url,
        request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<UserAddress>.fromJson(
            jsonMap,
                (data) => UserAddress.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error create user address");
      }
    } catch (e) {
      throw Exception("Error create user address: $e");
    }
  }

  Future<UserAddress?> updateAddress(UpdateAddressRequest request) async {
    String url = "$baseUrl/addresses/${request.addressId}";
    try {
      final response = await ApiClient.put(
        url,
        request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<UserAddress>.fromJson(
            jsonMap,
                (data) => UserAddress.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error update user address");
      }
    } catch (e) {
      throw Exception("Error update user address: $e");
    }
  }

}