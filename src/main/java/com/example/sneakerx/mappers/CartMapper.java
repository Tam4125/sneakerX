package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.cart.CartDto;
import com.example.sneakerx.dtos.cart.CartItemDto;
import com.example.sneakerx.entities.Cart;
import com.example.sneakerx.entities.CartItem;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface CartMapper {
    @Mapping(source = "user.userId", target = "userId")
    CartDto toCartDto(Cart cart);

    @Mapping(source = "cart.cartId", target = "cartId")
    @Mapping(source = "productSku.skuId", target = "skuId")
    CartItemDto toCartItemDto(CartItem cartItem);
}
