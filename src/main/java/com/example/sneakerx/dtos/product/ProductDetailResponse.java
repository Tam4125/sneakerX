package com.example.sneakerx.dtos.product;

import com.example.sneakerx.dtos.shop.ShopDto;
import com.example.sneakerx.entities.Category;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ProductDetailResponse {
    private ProductDto product;
    private Category category;
    private ShopDto shop;
    private List<ProductAttributeDto> attributes;
    private List<ProductSkuDto> skus;
    private List<ProductReviewDto> reviews;
}
