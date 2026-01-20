package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.product.*;
        import com.example.sneakerx.entities.*;
        import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {ShopMapper.class}
)
public interface ProductMapper {

    @Mapping(source = ".", target = "product")
    @Mapping(source = "shop", target = "shop")
    @Mapping(source = "category", target = "category")
    @Mapping(source = "attributes", target = "attributes")
    @Mapping(source = "skus", target = "skus")
    @Mapping(source = "reviews", target = "reviews")
    ProductDetailResponse toDetailResponse(Product product);

    // Product Entity -> DTO
    @Mapping(source = "shop.shopId", target = "shopId")
    @Mapping(source = "category.categoryId", target = "categoryId")
    ProductDto toProductDto(Product product);

    // Attribute Entity -> DTO
    @Mapping(source = "product.productId", target = "productId")
    ProductAttributeDto toAttributeDto(ProductAttribute attribute);

    // Attribute Value Entity -> DTO
    @Mapping(source = "attribute.attributeId", target = "attributeId")
    AttributeValueDto toAttributeValueDto(AttributeValue value);

    // SKU Entity -> DTO
    @Mapping(source = "product.productId", target = "productId")
    @Mapping(source = "values", target = "values")
    ProductSkuDto toSkuDto(ProductSku sku);

    @Mapping(source = "product.productId", target = "productId")
    @Mapping(source = "user.userId", target = "userId")
    ProductReviewDto toProductReviewDto(ProductReview productReview);

    @Mapping(source = "product.productId", target = "productId")
    ProductImageDto toProductImageDto(ProductImage productImage);
}