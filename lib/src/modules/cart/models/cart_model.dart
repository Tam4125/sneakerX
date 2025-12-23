// --- MODEL RIÊNG CHO CART ---
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/cart_item.dart';
import 'package:sneakerx/src/models/product_variant.dart';

class CartItemModel {
  final String name;
  final double price;
  final String imageUrl;
  final String size;
  final String colorName;
  final int itemId;
  int quantity;

  CartItemModel({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.colorName,
    required this.itemId,
    this.quantity = 1,
  });

  factory CartItemModel.fromCartItem(CartItem cartItem) {
    final sizeVariants = cartItem.product.variants.where((map) => map.variantId == cartItem.sizeId);
    ProductVariant sizeVariant = sizeVariants.first;

    final colorVariants = cartItem.product.variants.where((map) => map.variantId == cartItem.colorId);
    ProductVariant colorVariant = colorVariants.first;

    return CartItemModel(
      name: cartItem.product.name,
      quantity: cartItem.quantity,
      imageUrl: cartItem.product.images.first.imageUrl,
      size: sizeVariant.variantValue,
      colorName: AppConfig.getColorName(colorVariant.variantValue),
      itemId: cartItem.itemId,
      price: sizeVariant.price
    );

  }


}