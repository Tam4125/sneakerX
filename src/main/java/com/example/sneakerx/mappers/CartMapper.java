package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.cart.CartDto;
import com.example.sneakerx.dtos.cart.CartItemDto;
import com.example.sneakerx.entities.Cart;
import com.example.sneakerx.entities.CartItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CartMapper {
    private final ProductMapper productMapper;

    public CartDto mapToCartDto(Cart cart) {
        CartDto cartDto = new CartDto();
        cartDto.setCartId(cart.getCartId());
        cartDto.setUserId(cart.getUser().getUserId());
        cartDto.setCartItems(
                cart.getCartItems().stream().map(
                        this::mapToCartItemDto
                ).toList()
        );

        return cartDto;
    }

    public CartItemDto mapToCartItemDto(CartItem cartItem) {
        CartItemDto cartItemDto = new CartItemDto();
        cartItemDto.setItemId(cartItem.getItemId());
        cartItemDto.setSizeId(cartItem.getSizeId());
        cartItemDto.setColorId(cartItem.getColorId());
        cartItemDto.setProduct(productMapper.mapToDetailResponse(cartItem.getProduct()));
        cartItemDto.setQuantity(cartItem.getQuantity());
        return cartItemDto;
    }
}
