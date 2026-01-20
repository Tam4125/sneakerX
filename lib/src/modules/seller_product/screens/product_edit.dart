import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/models/product_attribute.dart';
import 'package:sneakerx/src/modules/product_detail/dtos/product_detail_response.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_attribute_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_attribute_value_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/create_sku_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/update_product_request.dart';
import 'package:sneakerx/src/modules/seller_product/models/update_sku_request.dart';
import 'package:sneakerx/src/services/category_service.dart';
import 'package:sneakerx/src/services/media_service.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();
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
  late Future<ApiResponse<ProductDetailResponse>> _dataFuture;
  bool _isDataPopulated = false; // Ensures we only fill controllers once
  bool _isUploading = false;
  String _statusMessage = "Save Changes";

  // Data from API
  List<ProductCategory> _categories = [];
  List<ProductAttribute> _commonAttributes = [];

  // Selection
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  // --- DRAFT DATA (UI State) ---
  // Images: We need to separate existing URLs from new Local Files
  List<ExistingImage> _existingImages = [];
  final List<File> _newLocalImages = [];

  bool _hasVariants = false;
  final List<DraftAttribute> _draftAttributes = [];
  List<DraftSku> _generatedSkus = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = _productService.getProductById(widget.productId);
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Fetch Lookups
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

  // Map Backend Data to UI Draft Models
  void _populateData(ProductDetailResponse data) {
    if (_isDataPopulated) return;

    // Basic Info
    _nameCtrl.text = data.product.name;
    _descCtrl.text = data.product.description;
    _basePriceCtrl.text = data.product.basePrice.toString();
    _selectedCategoryId = data.product.categoryId;
    _selectedCategoryName = data.category.name;

    // Images
    _existingImages = data.product.images.map((img) => ExistingImage(
        id: img.imageId,
        url: img.imageUrl
    )).toList();

    // Attributes
    if (data.attributes.isNotEmpty) {
      _hasVariants = true;
      for(var attrDto in data.attributes) {
        var draftAttr = DraftAttribute(id: attrDto.attributeId);
        draftAttr.name = attrDto.name;

        for (var valDto in attrDto.values) {
          draftAttr.values.add(DraftValue(
              id: valDto.valueId,
              value: valDto.value,
              uploadedUrl: valDto.imageUrl
          ));
        }
        _draftAttributes.add(draftAttr);
      }
    }

    // SKUs
    if (data.skus.isNotEmpty) {
      if (data.skus.length == 1 && data.skus.first.skuCode.contains("DEFAULT")) {
        _hasVariants = false;
        _stockCtrl.text = data.skus.first.stock.toString();
      } else {
        for (var skuDto in data.skus) {
          // Reconstruct specifications map for UI matching
          Map<String, String> specs = {};
          for (var val in skuDto.values) {
            // We need to find the attribute name for this value
            var parentAttr = _draftAttributes.firstWhere((a) => a.id == val.attributeId, orElse: () => DraftAttribute());
            if (parentAttr.name.isNotEmpty) {
              specs[parentAttr.name] = val.value;
            }
          }

          _generatedSkus.add(DraftSku(
            id: skuDto.skuId,
            code: skuDto.skuCode,
            price: skuDto.price,
            stock: skuDto.stock,
          )..specs = specs);
        }
      }
    }

    _isDataPopulated = true;
  }

  // --- LOGIC: IMAGE PICKERS ---
  Future<void> _pickMainImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _newLocalImages.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _pickValueImage(DraftValue val) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => val.localFile = File(image.path));
    }
  }

  // --- LOGIC: SKU GENERATION ---
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

    List<DraftSku> previousSkus = List.from(_generatedSkus);

    setState(() {
      _generatedSkus = combinations.map((combo) {
        String code = combo.values.join("-").toUpperCase();

        DraftSku? existingMatch;
        try {
          existingMatch = previousSkus.firstWhere((oldSku) {
            // Compare the two Maps: {Color: Red, Size: 42} vs {Color: Red, Size: 42}
            return mapEquals(oldSku.specs, combo);
          });
        } catch (_) {
          // No match found (New variant)
        }

        return DraftSku(
          id: existingMatch?.id, // Keep ID if updating
          price: existingMatch?.price ?? double.tryParse(_basePriceCtrl.text) ?? 0,
          stock: existingMatch?.stock ?? 0,
        )
          ..code = code
          ..specs = combo;
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

  // --- LOGIC: SUBMIT ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Handle category text input
    if (_selectedCategoryId == null) {
      GlobalSnackbar.show(context, success: false, message: "Please select or type a category");
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = "Updating...";
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final int shopId = auth.shopId!;

    try {
      // 1. UPLOAD NEW IMAGES
      List<String> uploadedNewUrls = [];
      if (_newLocalImages.isNotEmpty) {
        final uploadRes = await _mediaService.uploadProductMedia(_newLocalImages, shopId, widget.productId);
        if (uploadRes.success && uploadRes.data != null) {
          uploadedNewUrls = uploadRes.data!;
        }
      }

      // 2. UPLOAD ATTRIBUTE IMAGES
      for (var attr in _draftAttributes) {
        for (var val in attr.values) {
          if (val.localFile != null) {
            final valUpRes = await _mediaService.uploadProductMedia([val.localFile!], shopId, widget.productId);
            if (valUpRes.success && valUpRes.data!.isNotEmpty) {
              val.uploadedUrl = valUpRes.data!.first;
            }
          }
        }
      }

      // 3. PREPARE REQUEST MAPS

      // A. Attributes Logic
      Map<int, List<int>> keepAttributesKeepValues = {};
      Map<int, List<CreateAttributeValueRequest>> keepAttributesNewValues = {};
      List<CreateAttributeRequest> newAttributes = [];

      for (var attr in _draftAttributes) {
        if (attr.id != null) {
          // EXISTING ATTRIBUTE
          List<int> existingValIds = [];
          List<CreateAttributeValueRequest> newVals = [];

          for (var val in attr.values) {
            if (val.id != null) {
              existingValIds.add(val.id!);
            } else {
              newVals.add(CreateAttributeValueRequest(
                  value: val.value,
                  imageUrl: val.uploadedUrl
              ));
            }
          }
          keepAttributesKeepValues[attr.id!] = existingValIds;
          if (newVals.isNotEmpty) {
            keepAttributesNewValues[attr.id!] = newVals;
          }
        } else {
          // NEW ATTRIBUTE
          newAttributes.add(CreateAttributeRequest(
              name: attr.name,
              values: attr.values.map((v) => CreateAttributeValueRequest(
                  value: v.value,
                  imageUrl: v.uploadedUrl
              )).toList()
          ));
        }
      }

      // B. SKUs Logic
      List<UpdateSkuRequest> existingSkus = [];
      List<CreateSkuRequest> newSkus = [];

      // If variants turned off, create 1 default
      if (!_hasVariants) {
        _generatedSkus = [DraftSku(
          id: _generatedSkus.isNotEmpty ? _generatedSkus.first.id : null,
          price: double.parse(_basePriceCtrl.text),
          stock: int.tryParse(_stockCtrl.text) ?? 0,
        )..code = "DEFAULT"];
      }

      for (var dSku in _generatedSkus) {
        String fullCode = dSku.code == "DEFAULT"
            ? "${_nameCtrl.text.substring(0, 3).toUpperCase()}-DEFAULT"
            : "${_nameCtrl.text.substring(0, 3).toUpperCase()}-${dSku.code}";

        if (dSku.id != null) {
          existingSkus.add(UpdateSkuRequest(
              skuId: dSku.id!,
              price: dSku.price,
              stock: dSku.stock
          ));
        } else {
          newSkus.add(CreateSkuRequest(
              skuCode: fullCode,
              price: dSku.price,
              stock: dSku.stock,
              specifications: dSku.specs
          ));
        }
      }

      // 4. CONSTRUCT REQUEST
      final updateRequest = UpdateProductRequest(
        productId: widget.productId,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        basePrice: double.parse(_basePriceCtrl.text),
        shopId: shopId,
        categoryId: _selectedCategoryId!,
        // Images
        keepImages: _existingImages.map((e) => e.id).toList(),
        newImageUrls: uploadedNewUrls,
        // Attributes
        keepAttributesKeepValues: keepAttributesKeepValues,
        keepAttributesNewValues: keepAttributesNewValues,
        newAttributes: newAttributes,
        // SKUs
        existingSkus: existingSkus,
        newSkus: newSkus,
      );

      final response = await _shopService.updateProduct(updateRequest);

      if (response.success) {
        GlobalSnackbar.show(context, success: true, message: "Product Updated Successfully!");
        if (mounted) Navigator.pop(context, true);
      } else {
        GlobalSnackbar.show(context, success: false, message: response.message);
      }

    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Error: $e");
    } finally {
      if (mounted) setState(() { _isUploading = false; _statusMessage = "Save Changes"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit Product", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
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
      body: FutureBuilder<ApiResponse<ProductDetailResponse>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading product"));
          }
          if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: Text("Product not found"));
          }

          // Populate fields ONCE
          _populateData(snapshot.data!.data!);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Basic Information"),
                  _buildTextField("Product Name", _nameCtrl),
                  const SizedBox(height: 16),

                  // Category Autocomplete (Same as Create Screen)
                  _buildLabel("Category"),
                  Autocomplete<ProductCategory>(
                    initialValue: TextEditingValue(text: _selectedCategoryName ?? ""),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text == '') return _categories;
                      return _categories.where((opt) => opt.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (opt) => opt.name,
                    onSelected: (selection) {
                      setState(() {
                        _selectedCategoryId = selection.categoryId;
                        _selectedCategoryName = selection.name;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _inputDecoration(hint: "Category"),
                        onChanged: (val) {
                          _selectedCategoryId = null; // Reset ID if user types new name
                          _selectedCategoryName = val;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildTextField("Description", _descCtrl, maxLines: 3),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Images"),
                  _buildImageSection(),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Pricing & Inventory"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Base Price", _basePriceCtrl, isNumber: true, prefix: "\$")),
                      const SizedBox(width: 16),
                    ],
                  ),

                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("This product has variants?"),
                    value: _hasVariants,
                    activeColor: Colors.black,
                    onChanged: (val) => setState(() {
                      _hasVariants = val;
                      _generateSkus();
                    }),
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
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER: IMAGES ---
  Widget _buildImageSection() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _pickMainImages,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_a_photo, color: Colors.grey),
            ),
          ),
          // EXISTING IMAGES (Network)
          ..._existingImages.map((img) => Stack(
            children: [
              Container(
                width: 100, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: NetworkImage(img.url), fit: BoxFit.cover)
                ),
              ),
              Positioned(
                right: 16, top: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _existingImages.remove(img)),
                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                ),
              )
            ],
          )),
          // NEW LOCAL IMAGES (File)
          ..._newLocalImages.map((file) => Stack(
            children: [
              Container(
                width: 100, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                ),
              ),
              Positioned(
                right: 16, top: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _newLocalImages.remove(file)),
                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  // --- UI COMPONENTS (Reused) ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
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
                  onChanged: (val) {
                    attr.name = val;
                    _generateSkus();
                  },
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
                  : (v.uploadedUrl != null ? CircleAvatar(backgroundImage: NetworkImage(v.uploadedUrl!)) : null),
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
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if(attr.values.isNotEmpty) _pickValueImage(attr.values.last);
                else {
                  GlobalSnackbar.show(context, success: false, message: "Add a new value first!");
                }
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: "Add image to last value",
            ),
            IconButton(
              onPressed: () {
                if(valCtrl.text.isNotEmpty) {
                  setState(() {
                    attr.values.add(DraftValue(value: valCtrl.text));
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(sku.code, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: TextFormField(
            initialValue: sku.price.toString(),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(hint: "Price").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
            onChanged: (v) => sku.price = double.tryParse(v) ?? 0,
          )),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(
            initialValue: sku.stock.toString(),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(hint: "Stock").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
            onChanged: (v) => sku.stock = int.tryParse(v) ?? 0,
          )),
        ],
      ),
    );
  }
}

// --- UPDATED DRAFT MODELS (With IDs) ---
class ExistingImage {
  int id;
  String url;
  ExistingImage({required this.id, required this.url});
}

class DraftAttribute {
  int? id; // Null if new
  String name = "";
  List<DraftValue> values = [];
  DraftAttribute({this.id});
}

class DraftValue {
  int? id; // Null if new
  String value = "";
  File? localFile;
  String? uploadedUrl;
  DraftValue({this.id, required this.value, this.uploadedUrl});
}

class DraftSku {
  int? id; // Null if new
  String code = "";
  Map<String, String> specs = {};
  double price = 0;
  int stock = 0;
  DraftSku({this.id, this.price = 0, this.stock = 0, this.code = ""});
}