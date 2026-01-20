import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/product_sku.dart';

class OrderItem {
  final int orderItemId;
  final int shopOrderId;
  final Product product;
  final ProductSku sku;
  final String productNameSnapshot;
  final String skuNameSnapshot;
  final double priceAtPurchase;
  final int quantity;

  OrderItem({
    required this.orderItemId,
    required this.shopOrderId,
    required this.product,
    required this.sku,
    required this.productNameSnapshot,
    required this.skuNameSnapshot,
    required this.priceAtPurchase,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['orderItemId'],
      shopOrderId: json['shopOrderId'],
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      sku: ProductSku.fromJson(json['sku'] as Map<String, dynamic>),
      productNameSnapshot: json['productNameSnapshot'],
      skuNameSnapshot: json['skuNameSnapshot'],
      priceAtPurchase: json['priceAtPurchase'],
      quantity: json['quantity']
    );
  }
}