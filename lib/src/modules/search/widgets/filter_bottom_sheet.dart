import 'package:flutter/material.dart';
import '../models_search/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilter;
  final Function(FilterOptions) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions filter;

  final List<String> brands = ['Nike', 'Adidas', 'New Balance', 'MLB'];
  final List<String> priceRanges = [
    'Dưới 1 triệu',
    '1 - 2 triệu',
    '2 - 5 triệu',
    'Trên 5 triệu',
  ];

  @override
  void initState() {
    super.initState();
    filter = FilterOptions(
      selectedBrands: List.from(widget.initialFilter.selectedBrands),
      priceRange: widget.initialFilter.priceRange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ lọc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Filter
                  Text(
                    'Thương hiệu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      final isSelected = filter.selectedBrands.contains(brand);
                      return FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              filter.selectedBrands.add(brand);
                            } else {
                              filter.selectedBrands.remove(brand);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.orange[100],
                        checkmarkColor: Colors.orange[700],
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Price Range Filter
                  Text(
                    'Khoảng giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...priceRanges.map((range) {
                    return RadioListTile<String>(
                      title: Text(range),
                      value: range,
                      groupValue: filter.priceRange,
                      onChanged: (value) {
                        setState(() {
                          filter.priceRange = value;
                        });
                      },
                      activeColor: Colors.orange[700],
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Footer Buttons
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filter = FilterOptions();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.orange[700]!),
                    ),
                    child: Text(
                      'Đặt lại',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(filter);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange[700],
                    ),
                    child: Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}