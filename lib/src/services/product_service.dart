import 'package:dio/dio.dart';
import 'package:sneakerx/src/models/product_attribute.dart';
import 'package:sneakerx/src/models/product_review.dart';
import 'package:sneakerx/src/modules/product_detail/dtos/product_detail_response.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_review_request.dart';
import 'package:sneakerx/src/modules/search/dtos/filter_query.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/models/product.dart';

class ProductService {
  static const String _productPath = "/products";

  // Fetch Product Detail by ID
  Future<ApiResponse<ProductDetailResponse>> getProductById(int productId) async {
    final endpoint = "$_productPath/$productId";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => ProductDetailResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Get product detail failed",
        data: null
      );
    }
  }

  // Fetch List of Popular Products
  Future<ApiResponse<List<Product>>> fetchPopularProducts({int page = 0, int size = 10}) async {
    final endpoint = "$_productPath/popular?page=$page&size=$size";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
        response.data,
          (data) => ((data as Map<String, dynamic>?)?['content'] as List?)
            ?.map((ele) => Product.fromJson(ele as Map<String, dynamic>))
            .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Get popular products failed",
        data: null
      );
    }
  }

  // Fetch List of Favourite Products
  Future<ApiResponse<List<Product>>> fetchFavouriteProducts({int page = 0, int size = 10}) async {
    final endpoint = "$_productPath/favourite?page=$page&size=$size";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
          response.data,
            (data) => ((data as Map<String, dynamic>?)?['content'] as List?)
              ?.map((ele) => Product.fromJson(ele as Map<String, dynamic>))
              .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get favourite products failed",
          data: null
      );
    }
  }

  Future<ApiResponse<List<ProductAttribute>>> fetchPopularAttributes({int page = 0, int size = 10}) async {
    final endpoint = "$_productPath/attributes/popular?page=$page&size=$size";

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
          response.data,
              (data) => ((data as Map<String, dynamic>?)?['content'] as List?)
              ?.map((ele) => ProductAttribute.fromJson(ele as Map<String, dynamic>))
              .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Get popular attributes failed",
          data: null
      );
    }
  }

  // Fetch List of Search Products
  Future<ApiResponse<List<Product>>> searchProducts(FilterQuery query, {int page = 0, int size = 20}) async {
    String endpoint = "$_productPath?page=$page&size=$size";

    // 1. Keyword
    if (query.q != null && query.q!.isNotEmpty) {
      endpoint += "&q=${query.q}";
    }

    // 2. Category ID (CHANGED)
    // Backend expects: @RequestParam Long categoryId
    if (query.categoryId != null) {
      endpoint += "&categoryId=${query.categoryId}";
    }

    // 3. Min Price
    if (query.minPrice != null) {
      endpoint += "&minPrice=${query.minPrice}";
    }

    // 4. Max Price
    if (query.maxPrice != null) {
      endpoint += "&maxPrice=${query.maxPrice}";
    }

    try {
      final response = await ApiClient.get(endpoint);

      return ApiResponse.fromJson(
          response.data,
              (data) => ((data as Map<String, dynamic>?)?['content'] as List?)
              ?.map((ele) => Product.fromJson(ele as Map<String, dynamic>))
              .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Search products failed",
          data: null
      );
    }
  }

  Future<ApiResponse<List<ProductReview>>> createReviews(CreateReviewRequest request) async {
    final endpoint = "$_productPath/reviews";

    print("CREATE REVIEWS REQUEST??? : ${request.toJson()}");

    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      print("CREATE REVIEWS RESPONSE??? : ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => (data as List?)
            ?.map((ele) => ProductReview.fromJson(ele as Map<String, dynamic>))
            .toList() ?? []
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Create reviews failed",
        data: null
      );
    }
  }

}