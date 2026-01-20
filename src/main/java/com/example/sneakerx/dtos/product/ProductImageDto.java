package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductImageDto {
    private Integer imageId;
    private Integer productId;
    private String imageUrl;
}
