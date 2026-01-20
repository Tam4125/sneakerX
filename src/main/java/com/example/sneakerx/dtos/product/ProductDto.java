package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductDto {
    private Integer productId;
    private Integer categoryId;
    private Integer shopId;
    private String name;
    private String description;
    private Double basePrice;
    private Integer soldCount;
    private Double rating;
    private LocalDateTime createdAt;

    private List<ProductImageDto> images;
}
