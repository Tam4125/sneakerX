
import 'package:sneakerx/src/models/cart_item.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/product.dart';

class OrderItemModel {
  final String productName;
  final String productImage;
  final String size;
  final String color;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productName,
    required this.productImage,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromOrderItem(OrderItem orderItem) {

    Product product = orderItem.product;

    final color = product.variants.where((map) => map.variantType=="COLOR" && map.variantId == orderItem.colorId).first.variantValue;
    final sizeVariant = product.variants.where((map) => map.variantType=="SIZE" && map.variantId == orderItem.sizeId).first;
    final size = sizeVariant.variantValue;
    final imageUrl = product.images.first.imageUrl;
    final price = orderItem.price;

    return OrderItemModel(
      productName: product.name,
      productImage: imageUrl,
      size: size,
      color: color,
      price: price,
      quantity: orderItem.quantity,
    );
  }

}