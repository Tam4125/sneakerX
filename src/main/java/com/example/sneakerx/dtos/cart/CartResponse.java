package com.example.sneakerx.dtos.cart;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CartResponse {
    private Integer cartId;
    private Integer userId;
    private List<CartItemResponse> cartItems;
}
