package com.example.sneakerx.dtos.cart;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CartItemDto {
    private Integer itemId;
    private Integer sizeId;
    private Integer colorId;
    private Integer quantity;
    private ProductDetailResponse product;
}
