package com.example.sneakerx.services;

import com.example.sneakerx.dtos.cart.CartItemResponse;
import com.example.sneakerx.dtos.cart.CartResponse;
import com.example.sneakerx.dtos.cart.SaveToCartRequest;
import com.example.sneakerx.dtos.cart.UpdateCartRequest;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.CartMapper;
import com.example.sneakerx.repositories.CartItemRepository;
import com.example.sneakerx.repositories.CartRepository;
import com.example.sneakerx.repositories.ProductSkuRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartService {
    // Repository
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductSkuRepository productSkuRepository;

    // Utils
    private final CartMapper cartMapper;

    private CartItemResponse toCartItemResponse(CartItem cartItem) {
        ProductSku sku = cartItem.getProductSku();
        Product product = sku.getProduct();

        // Logic to build readable variant string: "Red, 42"
        String variants = sku.getValues().stream()
                .map(AttributeValue::getValue)
                .collect(Collectors.joining(", "));

        String img = product.getImages().isEmpty() ? "" : product.getImages().get(0).getImageUrl();

        return CartItemResponse.builder()
                .itemId(cartItem.getItemId())
                .skuId(sku.getSkuId())
                .productId(product.getProductId())
                .shopId(product.getShop().getShopId())
                .shopName(product.getShop().getShopName())
                .productName(product.getName())
                .productImageUrl(img)
                .variantDescription(variants)
                .quantity(cartItem.getQuantity())
                .unitPrice(sku.getPrice())
                .subTotal(sku.getPrice() * cartItem.getQuantity())
                .currentStock(sku.getStock())
                .available(sku.getStock() >= cartItem.getQuantity())
                .build();
    }

    public CartResponse getCurrentUserCart(User user) {
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        List<CartItemResponse> cartItems = cart.getCartItems().stream().map(
                this::toCartItemResponse
        ).toList();

        return CartResponse.builder()
                .userId(cart.getUser().getUserId())
                .cartId(cart.getCartId())
                .cartItems(cartItems)
                .build();
    }

    public CartResponse saveToCart(SaveToCartRequest request, User user) {

        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        ProductSku productSku = productSkuRepository.findBySkuId(request.getSkuId())
                .orElseThrow(() -> new ResourceNotFoundException("Product Sku not found"));


        CartItem newCartItem = CartItem.builder()
                .cart(cart)
                .productSku(productSku)
                .quantity(request.getQuantity())
                .build();

        cart.getCartItems().add(newCartItem);
        Cart savedCart = cartRepository.save(cart);

        List<CartItemResponse> cartItems = savedCart.getCartItems().stream().map(
                this::toCartItemResponse
        ).toList();

        return CartResponse.builder()
                .userId(savedCart.getUser().getUserId())
                .cartId(savedCart.getCartId())
                .cartItems(cartItems)
                .build();
    }

    public CartResponse deleteCartItem(Integer itemId, User user) {
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        CartItem deletedCartItem = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("Deleted item not found"));

        cart.getCartItems().remove(deletedCartItem);

        Cart savedCart = cartRepository.save(cart);

        List<CartItemResponse> cartItems = savedCart.getCartItems().stream().map(
                this::toCartItemResponse
        ).toList();

        return CartResponse.builder()
                .userId(savedCart.getUser().getUserId())
                .cartId(savedCart.getCartId())
                .cartItems(cartItems)
                .build();
    }

    public CartResponse updateCart(UpdateCartRequest request, User user) {
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        List<CartItem> cartItems = cart.getCartItems();
        Map<Integer, Integer> updates = request.getUpdatedQuantities();

        // Loop through existing DB items
        for(CartItem cartItem : cartItems) {
            // CRITICAL FIX: Check if the update map actually contains this item ID
            if (updates.containsKey(cartItem.getItemId())) {
                Integer newQuantity = updates.get(cartItem.getItemId());

                // VALIDATION: Ensure quantity is valid
                if (newQuantity != null && newQuantity > 0) {
                    cartItem.setQuantity(newQuantity);
                }
            }
        }

        Cart savedCart = cartRepository.save(cart);

        return CartResponse.builder()
                .cartId(savedCart.getCartId())
                .userId(savedCart.getUser().getUserId())
                .cartItems(savedCart.getCartItems().stream().map(this::toCartItemResponse).toList())
                .build();
    }
}
