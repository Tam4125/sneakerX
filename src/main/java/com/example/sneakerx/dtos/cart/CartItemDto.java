package com.example.sneakerx.dtos.cart;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CartItemDto {
   private Integer itemId;
   private Integer cartId;
   private Integer skuId;
   private Integer quantity;
}