import 'package:dio/dio.dart';
import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class CategoryService {
  static const String _categoryPath = "/categories";

  Future<ApiResponse<List<ProductCategory>>> getCategories() async {
    final endpoint = "$_categoryPath";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
          response.data,
              (data) => (data as List?)
                ?.map((ele) => ProductCategory.fromJson(ele as Map<String, dynamic>))
                .toList() ?? []
      );
    } on DioException catch (e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ??
              "Service Error: Get categories failed",
          data: null
      );
    }
  }
}