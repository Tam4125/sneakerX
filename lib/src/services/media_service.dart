import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class MediaService {
  static const String _mediaPath = "/media";

  Future<ApiResponse<String>> uploadUserAvatar(File? avatarImage, int userId) async {
    final endpoint = "$_mediaPath/users/$userId";

    print("UPLOAD USER AVATAR REQUEST???: ${avatarImage}");

    try {
      final response = await ApiClient.postMultipart(
        url: endpoint,
        fileField: 'avatarImage',
        file: avatarImage
      );

      print("UPLOAD USER AVATAR RESPONSE???: ${response.data}");

      return ApiResponse(
        success: true,
        message: response.data['message'],
        data: response.data['data']
      );

    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Upload user avatar failed",
        data: null
      );
    }
  }

  Future<ApiResponse<String>> uploadShopAvatar(File? avatarImage, int shopId) async {
    final endpoint = "$_mediaPath/shops/$shopId";

    print("UPLOAD SHOP AVATAR REQUEST???: ${avatarImage}");

    try {
      final response = await ApiClient.postMultipart(
          url: endpoint,
          fileField: 'avatarImage',
          file: avatarImage
      );

      print("UPLOAD SHOP AVATAR RESPONSE???: ${response.data}");

      return ApiResponse(
          success: true,
          message: response.data['message'],
          data: response.data['data']
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Upload shop avatar failed",
          data: null
      );
    }
  }

  Future<ApiResponse<List<String>>> uploadProductMedia(List<File>? images, int shopId, int productId) async {
    final endpoint = "$_mediaPath/products?shopId=$shopId&productId=$productId";

    try {
      final response = await ApiClient.postMultipart(
          url: endpoint,
          fileField: 'images',
          files: images
      );
      final List<String> urls = List<String>.from(response.data['data']);
      return ApiResponse(
          success: true,
          message: response.data['message'],
          data: urls
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Upload product media failed",
          data: null
      );
    }
  }
}