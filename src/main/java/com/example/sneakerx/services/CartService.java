package com.example.sneakerx.services;

import com.example.sneakerx.dtos.cart.CartDto;
import com.example.sneakerx.dtos.cart.SaveToCartRequest;
import com.example.sneakerx.entities.Cart;
import com.example.sneakerx.entities.CartItem;
import com.example.sneakerx.entities.Product;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.CartMapper;
import com.example.sneakerx.repositories.CartItemRepository;
import com.example.sneakerx.repositories.CartRepository;
import com.example.sneakerx.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;

@Service
@RequiredArgsConstructor
public class CartService {
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CartMapper cartMapper;
    private final ProductRepository productRepository;

    public CartDto getCurrentUserCart(User user) {
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        return cartMapper.mapToCartDto(cart);
    }

    public CartDto saveToCart(SaveToCartRequest request, User user) throws AccessDeniedException {

        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        Product product = productRepository.findByProductId(request.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        CartItem newCartItem = CartItem.builder()
                .sizeId(request.getSizeId())
                .colorId(request.getColorId())
                .quantity(request.getQuantity())
                .product(product)
                .cart(cart)
                .build();

        cart.getCartItems().add(newCartItem);
        Cart savedCart = cartRepository.save(cart);

        return cartMapper.mapToCartDto(savedCart);
    }

    public CartDto deleteCartItem(Integer itemId, User user) throws AccessDeniedException {
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found"));

        CartItem deletedCartItem = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("Deleted item not found"));

        cart.getCartItems().remove(deletedCartItem);

        Cart savedCart = cartRepository.save(cart);

        return cartMapper.mapToCartDto(savedCart);
    }
}
