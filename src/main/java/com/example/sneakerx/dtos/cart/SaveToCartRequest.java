package com.example.sneakerx.dtos.cart;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SaveToCartRequest {
    private Integer sizeId;
    private Integer colorId;
    private Integer quantity;
    private Integer productId;
}
