import 'package:flutter/material.dart';
import '../models/checkout_models.dart'; // Import model

class ShippingMethodSheet extends StatelessWidget {
  final ShippingMethod selectedShipping;
  final Function(ShippingMethod) onShippingSelected;

  // Danh sách các gói vận chuyển
  final List<ShippingMethod> _shippingOptions = [
    ShippingMethod(id: 'GHN', name: "Giao Hàng Nhanh", estimateTime: "1-3 ngày", price: 30000),
    ShippingMethod(id: 'GHTK', name: "Giao Hàng Tiết Kiệm", estimateTime: "3-5 ngày", price: 15000),
    ShippingMethod(id: 'HOATOC', name: "Hỏa Tốc (Trong 2h)", estimateTime: "30 phút - 2 giờ", price: 50000),
  ];

  ShippingMethodSheet({
    super.key,
    required this.selectedShipping,
    required this.onShippingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text("Chọn phương thức vận chuyển", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: _shippingOptions.length,
              itemBuilder: (context, index) {
                final option = _shippingOptions[index];
                final isSelected = option.id == selectedShipping.id;

                return InkWell(
                  onTap: () {
                    onShippingSelected(option);
                    Navigator.pop(context); // Đóng popup sau khi chọn
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio button
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        // Thông tin
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Nhận hàng: ${option.estimateTime}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        // Giá tiền
                        Text(
                          "${option.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                          style: const TextStyle(color: Color(0xFF8B5FBF), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}