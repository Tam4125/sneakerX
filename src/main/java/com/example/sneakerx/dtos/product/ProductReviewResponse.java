package com.example.sneakerx.dtos.product;

import com.example.sneakerx.entities.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductReviewResponse {
    private Integer reviewId;
    private Double rating;
    private String comment;
    private Integer userId;
}
