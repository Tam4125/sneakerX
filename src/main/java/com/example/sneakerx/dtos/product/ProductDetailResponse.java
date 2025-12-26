package com.example.sneakerx.dtos.product;

import com.example.sneakerx.dtos.shop.ShopBasicInfo;
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
public class ProductDetailResponse {
    private Integer productId;
    private Integer categoryId;
    private Integer shopId;
    private String name;
    private String description;
    private Integer soldCount;
    private Double rating;
    private String status;
    private LocalDateTime createdAt;

    private List<ProductImageResponse> images;
    private List<ProductVariantResponse> variants;
    private List<ProductReviewResponse> reviews;
}
