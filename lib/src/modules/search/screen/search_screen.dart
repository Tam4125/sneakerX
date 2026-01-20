import 'package:flutter/material.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/search/widgets/product_list.dart';
import 'package:sneakerx/src/services/product_service.dart';
import '../widgets/search_bar_widget.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading =false;
  List<Product> suggestedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _productService.fetchPopularProducts();
      if(response.success) {
        suggestedProducts = response.data!;
      } else {
        GlobalSnackbar.show(context, success: false, message: "Get suggested products failed");
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Get suggested products failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          searchQuery: _searchController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          hintText: 'Search for product...',
          onSearch: _performSearch,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Suggestion for you',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            _isLoading
              ? Center(child: CircularProgressIndicator(),)
              : ProductList(products: suggestedProducts),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}