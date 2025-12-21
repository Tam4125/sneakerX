import 'dart:convert';

import 'package:http/http.dart' as http;
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

}