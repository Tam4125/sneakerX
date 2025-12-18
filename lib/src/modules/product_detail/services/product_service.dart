import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sneakerx/src/modules/product_detail/models/api_response.dart';
import 'package:sneakerx/src/modules/product_detail/models/product_detail.dart';

class ProductService {
  static const String baseUrl = "http://10.0.2.2:8080/products";

  // Fetch Product Detail by ID
  Future<ProductDetail?> getProductById(int productId) async {
    final url = Uri.parse("$baseUrl/$productId");

    try {
      final response = await http.get(url);

      if(response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<ProductDetail>.fromJson(
          jsonMap,
            (data) => ProductDetail.fromJson(data as Map<String, dynamic>)
        );

        if(apiResponse.success) {
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error fetching product: $e");
    }
  }
}