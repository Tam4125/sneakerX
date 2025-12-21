// import 'package:flutter/material.dart';
// import '../../../data/datasources/mock_product_data.dart';
// // import '../../../config/app_config.dart';
//
// class RecommendationGrid extends StatelessWidget {
//   const RecommendationGrid({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Lấy data từ Mock
//     final products = MockProductData.relatedProducts;
//
//     return Container(
//       color: Colors.grey[50], // Nền xám rất nhạt
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Column(
//         children: [
//           // 1. HEADER "CÓ THỂ BẠN CŨNG THÍCH" (ĐÃ BỎ SORT/FILTER & CANH GIỮA)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center, // Canh giữa tiêu đề
//               children: const [
//                 Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF8B5FBF), size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   "Có thể bạn cũng thích",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Color(0xFF8B5FBF)
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           // 2. GRID SẢN PHẨM (Giữ nguyên thiết kế đẹp)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: products.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.68,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemBuilder: (context, index) {
//                 return _buildProductCard(products[index]);
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   // Widget Card Sản phẩm
//   Widget _buildProductCard(RelatedProductModel item) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade100),
//         // Hiệu ứng đổ bóng nổi (Shadow)
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. ẢNH SẢN PHẨM
//           Expanded(
//             flex: 6,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: Image.network(
//                 item.imageUrl,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_,__,___) => Container(color: Colors.grey[200]),
//               ),
//             ),
//           ),
//
//           // 2. THÔNG TIN
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Tên sản phẩm
//                   Text(
//                     item.name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                         height: 1.2
//                     ),
//                   ),
//
//                   // Giá và Đã bán
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.formattedPrice,
//                         style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Sao vàng giả lập
//                           Row(
//                             children: const [
//                               Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
//                               Text(" 4.9", style: TextStyle(fontSize: 11, color: Colors.grey)),
//                             ],
//                           ),
//                           const Text("Đã bán 123", style: TextStyle(fontSize: 11, color: Colors.grey)),
//                         ],
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }