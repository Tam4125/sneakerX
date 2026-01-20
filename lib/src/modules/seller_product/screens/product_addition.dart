import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/models/product_attribute.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_attribute_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_attribute_value_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_product_model.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_sku_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/update_product_request.dart'; // Make sure this exists
import 'package:sneakerx/src/services/category_service.dart';
import 'package:sneakerx/src/services/media_service.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  final CategoryService _categoryService = CategoryService();
  final MediaService _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _basePriceCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();

  // --- STATE ---
  final List<File> _localImages = [];
  bool _hasVariants = false;
  bool _isUploading = false;
  String _statusMessage = "Publish Product";

  List<ProductCategory> _categories = [];
  List<ProductAttribute> _commonAttributes = [];

  int? _selectedCategoryId; // If null, check the text controller of autocomplete
  String? _selectedCategoryName;

  // --- DRAFT DATA FOR UI ---
  final List<DraftAttribute> _draftAttributes = [];
  List<DraftSku> _generatedSkus = [];


  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await _categoryService.getCategories();
      if(!response.success && response.data == null) {
        GlobalSnackbar.show(context, success: false, message: response.message);
        return;
      }

      _categories = response.data!;
    } catch(e) {
      GlobalSnackbar.show(context, success: false, message: "Service Error: Get popular categories failed {$e}");
    }

    try {
      final response = await _productService.fetchPopularAttributes();
      if(!response.success && response.data == null) {
        GlobalSnackbar.show(context, success: false, message: response.message);
        return;
      }

      _commonAttributes = response.data!;
    } catch(e) {
      GlobalSnackbar.show(context, success: false, message: "Service Error: Get popular attributes failed {$e}");
    }
  }

  // --- 1. IMAGE PICKERS ---
  Future<void> _pickMainImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _localImages.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _pickValueImage(DraftValue val) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => val.localFile = File(image.path));
    }
  }

  // --- 2. SKU LOGIC ---
  void _generateSkus() {
    if (_draftAttributes.isEmpty) {
      setState(() => _generatedSkus = []);
      return;
    }
    List<List<DraftValue>> input = _draftAttributes
        .map((attr) => attr.values)
        .where((vals) => vals.isNotEmpty)
        .toList();

    if (input.isEmpty) return;

    List<Map<String, String>> combinations = _cartesian(input);

    setState(() {
      _generatedSkus = combinations.map((combo) {
        String code = combo.values.join("-").toUpperCase();
        return DraftSku()
          ..code = code
          ..specs = combo
          ..price = double.tryParse(_basePriceCtrl.text) ?? 0
          ..stock = 0;
      }).toList();
    });
  }

  List<Map<String, String>> _cartesian(List<List<DraftValue>> input, [int index = 0, Map<String, String>? current]) {
    current ??= {};
    List<Map<String, String>> result = [];
    if (index == input.length) {
      result.add(Map.from(current));
      return result;
    }
    String attrName = _draftAttributes[index].name;
    for (var val in input[index]) {
      current[attrName] = val.value;
      result.addAll(_cartesian(input, index + 1, current));
    }
    return result;
  }

  // --- 3. SUBMIT FLOW (The 3-Step Process) ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      GlobalSnackbar.show(context, success: false, message: "Please select or type a category");
      return;
    }
    if (_localImages.isEmpty) {
      GlobalSnackbar.show(context, success: false, message: "Please add at least 1 image");
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = "Creating Product...";
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final int shopId = auth.shopId!;

    try {
      // --- STEP 1: CREATE SHELL PRODUCT (To get ID) ---
      // We send ONLY basic info. No attributes, no SKUs yet.
      final createRequest = CreateProductRequest(
        name: _nameCtrl.text,
        description: _descCtrl.text,
        basePrice: double.parse(_basePriceCtrl.text),
        shopId: shopId,
        categoryId: _selectedCategoryId!,
        // Logic: if category exists in DB, backend finds it by name. If not, creates new.
        imageUrls: [],
        attributes: [],
        skus: [],
      );

      final createRes = await _shopService.createProduct(createRequest);
      if (!createRes.success || createRes.data == null) {
        GlobalSnackbar.show(context, success: false, message: createRes.message);
      }
      final newProduct = createRes.data!;
      final productId = newProduct.product.productId; // Assuming DTO has this

      // --- STEP 2: UPLOAD MEDIA ---
      setState(() => _statusMessage = "Uploading Images...");

      // A. Main Images
      List<String> uploadedMainUrls = [];
      if (_localImages.isNotEmpty) {
        final uploadRes = await _mediaService.uploadProductMedia(_localImages, shopId, productId);
        if (uploadRes.success && uploadRes.data != null) {
          uploadedMainUrls = uploadRes.data!;
        }
      }

      // B. Attribute Images
      for (var attr in _draftAttributes) {
        for (var val in attr.values) {
          if (val.localFile != null) {
            final valUpRes = await _mediaService.uploadProductMedia([val.localFile!], shopId, productId);
            if (valUpRes.success && valUpRes.data!.isNotEmpty) {
              val.uploadedUrl = valUpRes.data!.first;
            }
          }
        }
      }

      // --- STEP 3: UPDATE PRODUCT WITH FULL DATA ---
      setState(() => _statusMessage = "Finalizing...");

      // Prepare SKUs
      List<CreateSkuRequest> skuRequests = _generatedSkus.map((dSku) {
        return CreateSkuRequest(
          skuCode: "${_nameCtrl.text.substring(0, 3).toUpperCase()}-${dSku.code}",
          price: dSku.price,
          stock: dSku.stock,
          specifications: dSku.specs,
        );
      }).toList();

      if (!_hasVariants) {
        skuRequests.add(CreateSkuRequest(
          skuCode: "${_nameCtrl.text.substring(0, 3).toUpperCase()}-DEFAULT",
          price: double.parse(_basePriceCtrl.text),
          stock: int.tryParse(_stockCtrl.text) ?? 0,
          specifications: {},
        ));
      }

      // Prepare Attributes
      List<CreateAttributeRequest> attrRequests = _draftAttributes.map((a) => CreateAttributeRequest(
          name: a.name,
          values: a.values.map((v) => CreateAttributeValueRequest(
              value: v.value,
              imageUrl: v.uploadedUrl
          )).toList()
      )).toList();

      // Construct Update Request
      // NOTE: We use the `new` fields in UpdateProductRequest to ADD these
      final updateRequest = UpdateProductRequest(
        productId: productId,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        basePrice: double.parse(_basePriceCtrl.text),
        shopId: shopId,
        categoryId: _selectedCategoryId!,
        newImageUrls: uploadedMainUrls, // Add images
        newAttributes: attrRequests,    // Add attributes
        newSkus: skuRequests, // Add SKUs
        keepImages: [],
        keepAttributesKeepValues: {},
        keepAttributesNewValues: {},
        existingSkus: [],
      );

      final updateRes = await _shopService.updateProduct(updateRequest);

      if (updateRes.success) {
        GlobalSnackbar.show(context, success: true, message: "Product Published Successfully!");
        if (mounted) Navigator.pop(context, true);
      } else {
        GlobalSnackbar.show(context, success: false, message: updateRes.message);
      }

    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Error: $e");
    } finally {
      if (mounted) setState(() { _isUploading = false; _statusMessage = "Publish Product"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Add New Product", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,-2))]),
        child: ElevatedButton(
          onPressed: _isUploading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isUploading
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 10),
            Text(_statusMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ])
              : Text(_statusMessage, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. BASIC INFO ---
              _buildSectionHeader("Basic Information"),
              _buildTextField("Product Name", _nameCtrl, hint: "e.g. Nike Air Jordan"),
              const SizedBox(height: 16),

              // Category Autocomplete
              _buildLabel("Category"),
              LayoutBuilder(
                builder: (context, constraints) => Autocomplete<ProductCategory>(
                  optionsBuilder: (textEditingValue) {

                    if (textEditingValue.text == '') return _categories;
                    return _categories.where((ProductCategory option) {
                      return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  // 2. Display Name in list
                  displayStringForOption: (ProductCategory option) => option.name,

                  // 3. Handle Selection
                  onSelected: (ProductCategory selection) {
                    setState(() {
                      _selectedCategoryId = selection.categoryId;
                      _selectedCategoryName = selection.name;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: _inputDecoration(hint: "Search existing category..."),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Category is required";
                        }

                        // STRICT CHECK: Input must match an existing category name
                        final exists = _categories.any(
                                (c) => c.name.toLowerCase() == value.toLowerCase()
                        );

                        if (!exists) {
                          return "Please select a valid category from the list";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        // Reset ID when typing; we will resolve it on submit or selection
                        _selectedCategoryId = null; // Reset ID if user types new name
                        _selectedCategoryName = val;
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              _buildTextField("Description", _descCtrl, maxLines: 3, hint: "Describe your product..."),

              const SizedBox(height: 24),

              // --- 2. IMAGES ---
              _buildSectionHeader("Product Images"),
              Container(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickMainImages,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!, width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, size: 30, color: Colors.grey),
                            const SizedBox(height: 4),
                            Text("Add Photo", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]))
                          ],
                        ),
                      ),
                    ),
                    ..._localImages.map((file) => Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0,2))]
                          ),
                        ),
                        Positioned(
                          top: 4, right: 16,
                          child: GestureDetector(
                            onTap: () => setState(() => _localImages.remove(file)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. PRICING & VARIANTS ---
              _buildSectionHeader("Pricing & Inventory"),
              Row(
                children: [
                  Expanded(child: _buildTextField("Base Price", _basePriceCtrl, isNumber: true, prefix: "\$")),
                  // const SizedBox(width: 16),
                  // Expanded(child: _buildTextField("Stock", _stockCtrl, isNumber: true, enabled: !_hasVariants)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: SwitchListTile(
                  title: Text("This product has variants", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Size, Color, Material...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _hasVariants,
                  activeColor: Colors.black,
                  onChanged: (val) {
                    setState(() => _hasVariants = val);
                    if (val) _generateSkus();
                  },
                ),
              ),

              if (_hasVariants) ...[
                const SizedBox(height: 24),
                _buildSectionHeader("Attributes"),
                ..._draftAttributes.asMap().entries.map((e) => _buildAttributeCard(e.key, e.value)).toList(),

                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                    label: const Text("Add Attribute", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    onPressed: () => setState(() => _draftAttributes.add(DraftAttribute())),
                  ),
                ),

                if (_generatedSkus.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader("Variants Setup"),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: Column(
                      children: _generatedSkus.map((sku) => _buildSkuRow(sku)).toList(),
                    ),
                  ),
                ]
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumber = false, int maxLines = 1, bool enabled = true, String? hint, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          enabled: enabled,
          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
          decoration: _inputDecoration(hint: hint, prefix: prefix).copyWith(
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeCard(int index, DraftAttribute attr) {
    TextEditingController valCtrl = TextEditingController();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0,2))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attribute #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              InkWell(
                onTap: () {
                  setState(() {
                    _draftAttributes.removeAt(index);
                    _generateSkus();
                  });
                },
                child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              )
            ],
          ),
          const SizedBox(height: 8),

          // Attribute Name Autocomplete
          LayoutBuilder(
            builder: (context, constraints) => Autocomplete<ProductAttribute>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') return _commonAttributes;
                return _commonAttributes.where((option) {
                  return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (option) => option.name,
              onSelected: (selection) {
                // If they select an existing attribute, we just use the name for now
                // (Backend handles matching by name string)
                attr.name = selection.name;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                if (attr.name.isNotEmpty && textEditingController.text.isEmpty) {
                  textEditingController.text = attr.name;
                }
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: _inputDecoration(hint: "Name (e.g. Size, Color)"),
                  onChanged: (val) => attr.name = val,
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attr.values.map((v) => Chip(
              label: Text(v.value),
              backgroundColor: Colors.grey[100],
              avatar: v.localFile != null
                  ? CircleAvatar(backgroundImage: FileImage(v.localFile!))
                  : null,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () {
                setState(() {
                  attr.values.remove(v);
                  _generateSkus();
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: valCtrl,
                decoration: _inputDecoration(hint: "Add Value (e.g. XL)"),
                onSubmitted: (_) {
                  if(valCtrl.text.isNotEmpty) {
                    setState(() {
                      attr.values.add(DraftValue()..value = valCtrl.text);
                      _generateSkus();
                    });
                    valCtrl.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if(attr.values.isNotEmpty) _pickValueImage(attr.values.last);
                else {
                  GlobalSnackbar.show(context, success: false, message: "Add a value first!");
                }
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: "Add image to last value",
            ),
            IconButton(
              onPressed: () {
                if(valCtrl.text.isNotEmpty) {
                  setState(() {
                    attr.values.add(DraftValue()..value = valCtrl.text);
                    _generateSkus();
                  });
                  valCtrl.clear();
                }
              },
              icon: const Icon(Icons.check_circle, color: Colors.black),
            )
          ])
        ],
      ),
    );
  }

  Widget _buildSkuRow(DraftSku sku) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sku.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sku.specs.values.join(" / "), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                initialValue: sku.price.toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(hint: "Price").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                onChanged: (val) => sku.price = double.tryParse(val) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                initialValue: sku.stock.toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(hint: "Stock").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                onChanged: (val) => sku.stock = int.tryParse(val) ?? 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DRAFT MODELS ---
class DraftAttribute {
  String name = "";
  List<DraftValue> values = [];
}

class DraftValue {
  String value = "";
  File? localFile;
  String? uploadedUrl;
}

class DraftSku {
  String code = "";
  Map<String, String> specs = {};
  double price = 0;
  int stock = 0;
}