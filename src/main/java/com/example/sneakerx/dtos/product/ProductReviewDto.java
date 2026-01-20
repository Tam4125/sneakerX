package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductReviewDto {
    private Integer reviewId;
    private Integer productId;
    private Integer userId;
    private Double rating;
    private String comment;
    private LocalDateTime createdAt;
}
