package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.product.ProductImageResponse;
import com.example.sneakerx.dtos.product.ProductReviewResponse;
import com.example.sneakerx.dtos.product.ProductVariantResponse;
import com.example.sneakerx.entities.Product;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ProductMapper {
    public ProductDetailResponse mapToDetailResponse(Product product) {
        ProductDetailResponse productDetailResponse = new ProductDetailResponse();

        productDetailResponse.setProductId(product.getProductId());
        productDetailResponse.setShopId(product.getShop().getShopId());
        productDetailResponse.setName(product.getName());
        productDetailResponse.setDescription(product.getDescription());
        productDetailResponse.setRating(product.getRating());
        productDetailResponse.setStatus(product.getStatus().name());
        productDetailResponse.setCategoryId(product.getCategory().getCategoryId());
        productDetailResponse.setCreatedAt(product.getCreatedAt());
        productDetailResponse.setSoldCount(product.getSoldCount());
        productDetailResponse.setImages(
                product.getImages().stream().map(img -> ProductImageResponse.builder()
                        .imageId(img.getImageId())
                        .imageUrl(img.getImageUrl())
                        .build()).toList()
        );
        productDetailResponse.setVariants(
                product.getVariants().stream().map(variant -> ProductVariantResponse.builder()
                        .variantId(variant.getVariantId())
                        .variantType(variant.getVariantType().name())
                        .variantValue(variant.getVariantValue())
                        .price(variant.getPrice())
                        .stock(variant.getStock())
                        .build()).toList()
        );
        if (product.getReviews() != null) {
            productDetailResponse.setReviews(
                    product.getReviews().stream().map(review -> ProductReviewResponse.builder()
                            .reviewId(review.getReviewId())
                            .comment(review.getComment())
                            .rating(review.getRating())
                            .userId(review.getUserId())
                            .build()).toList()
            );
        }
        return productDetailResponse;
    }
}
