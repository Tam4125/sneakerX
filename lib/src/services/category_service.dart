import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sneakerx/src/models/category.dart';

class CategoryService {
  static const String baseUrl = "http://10.0.2.2:8080/categories";

  Future<List<ProductCategory>?> getCategories({int page = 0, int size = 5}) async {
    final url = Uri.parse("$baseUrl?page=$page&size=$size");

    try {
      final response = await http.get(url);
      if(response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List list = jsonMap['data']['content'];

        return list.map((data) => ProductCategory.fromJson(data)).toList();

      }
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
    return null;
  }
}