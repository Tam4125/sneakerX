import 'package:flutter/material.dart';
import '../models/checkout_models.dart';

class VoucherBottomSheet extends StatelessWidget {
  final double currentSubTotal; // Tổng tiền hiện tại
  final Function(VoucherModel) onVoucherSelected; // Hàm callback khi chọn

  VoucherBottomSheet({
    super.key,
    required this.currentSubTotal,
    required this.onVoucherSelected,
  });

  final List<VoucherModel> _vouchers = [
    VoucherModel(
        id: '1', title: "Freeship Xtra", subtitle: "Giảm tối đa 30k ship",
        discountValue: 30000, minOrderValue: 0, isFreeShip: true
    ),
    VoucherModel(
        id: '2', title: "Giảm 150k", subtitle: "Đơn tối thiểu 5 triệu",
        discountValue: 150000, minOrderValue: 5000000, isFreeShip: false
    ),
    VoucherModel(
        id: '3', title: "Giảm 10%", subtitle: "Cho đơn từ 0đ",
        discountValue: 50000, minOrderValue: 0, isFreeShip: false
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text("Chọn Voucher", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: _vouchers.length,
              itemBuilder: (context, index) {
                final voucher = _vouchers[index];

                // --- LOGIC KIỂM TRA ĐIỀU KIỆN ---
                bool isEligible = currentSubTotal >= voucher.minOrderValue;

                return InkWell(
                  // Nếu không đủ điều kiện thì disable nút bấm
                  onTap: isEligible ? () {
                    onVoucherSelected(voucher);
                    Navigator.pop(context);
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      // Nếu không đủ điều kiện thì nền xám
                      color: isEligible ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isEligible ? const Color(0xFF8B5FBF) : Colors.grey.shade300
                      ),
                    ),
                    child: Opacity(
                      // Làm mờ nếu không đủ điều kiện
                      opacity: isEligible ? 1.0 : 0.5,
                      child: Row(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                                color: isEligible ? const Color(0xFF8B5FBF) : Colors.grey,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(9))
                            ),
                            child: Center(
                              child: Text(
                                voucher.isFreeShip ? "FREESHIP" : "GIẢM\nGIÁ",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(voucher.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(voucher.subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  const SizedBox(height: 5),
                                  // Hiển thị lý do nếu không đủ điều kiện
                                  if (!isEligible)
                                    Text(
                                      "Cần mua thêm ${formatCurrency(voucher.minOrderValue - currentSubTotal)}",
                                      style: const TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isEligible)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Radio(
                                value: true, groupValue: false,
                                activeColor: const Color(0xFF8B5FBF), onChanged: (v){},
                              ),
                            )
                        ],
                      ),
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

  String formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }
}