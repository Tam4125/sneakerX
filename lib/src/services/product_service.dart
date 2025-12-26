import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sneakerx/src/modules/search/dtos/filter_query.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/models/product.dart';

class ProductService {
  static const String baseUrl = "http://10.0.2.2:8080/products";

  // Fetch Product Detail by ID
  Future<Product?> getProductById(int productId) async {
    final url = Uri.parse("$baseUrl/$productId");

    try {
      final response = await http.get(url);

      if(response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<Product>.fromJson(
          jsonMap,
          (data) => Product.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;

      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // Fetch List of Popular Products
  Future<List<Product>?> fetchPopularProducts({int page = 0, int size = 10}) async {
    final url = Uri.parse("$baseUrl/popular?page=$page&size=$size");

    try {
      final response = await http.get(url);
      if(response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List list = jsonMap['data']['content'];

        return list.map((data) => Product.fromJson(data)).toList();

      }
    } catch (e) {
      throw Exception("Error fetching popular products: $e");
    }
    return null;
  }

  // Fetch List of Favourite Products
  Future<List<Product>?> fetchFavouriteProducts({int page = 0, int size = 10}) async {
    final url = Uri.parse("$baseUrl/popular?page=$page&size=$size");

    try {
      final response = await http.get(url);
      if(response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List list = jsonMap['data']['content'];

        return list.map((data) => Product.fromJson(data)).toList();
      }
    } catch (e) {
      throw Exception("Error fetching favourite products: $e");
    }
    return null;
  }

  // Fetch List of Search Products
  Future<List<Product>?> searchProducts(FilterQuery query, {int page = 0, int size = 20}) async {
    // Start with the base search endpoint
    // Note: Added /search if your backend endpoint is /products/search
    String url = "$baseUrl?page=$page&size=$size";

    // 1. Keyword
    if (query.q != null && query.q!.isNotEmpty) {
      url += "&q=${query.q}";
    }

    // 2. Category ID (CHANGED)
    // Backend expects: @RequestParam Long categoryId
    if (query.categoryId != null) {
      url += "&categoryId=${query.categoryId}";
    }

    // 3. Min Price
    if (query.minPrice != null) {
      url += "&minPrice=${query.minPrice}";
    }

    // 4. Max Price
    if (query.maxPrice != null) {
      url += "&maxPrice=${query.maxPrice}";
    }

    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Access the 'content' list inside the 'data' Page object
        final List list = jsonMap['data']['content'];

        return list.map((data) => Product.fromJson(data)).toList();
      }
    } catch (e) {
      throw Exception("Error searching products: $e");
    }
    return null;
  }

}