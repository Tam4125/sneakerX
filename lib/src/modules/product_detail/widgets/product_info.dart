import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../config/app_colors.dart';

class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(product.formattedPrice, style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Container(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: Colors.red[50], child: Text("-50%", style: TextStyle(color: Colors.red, fontSize: 12))),
              Spacer(),
              Text("Đã bán ${product.soldCount ~/ 1000}k+", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
          SizedBox(height: 8),
          Row(
            children: [
              Text("Giày thể thao", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(" ${product.rating} (1034)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}