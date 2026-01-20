package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateReviewRequest {
    private Integer userId;
    private List<Integer> productIds;
    private Map<Integer, Double> ratingMap; // {productId: rating}
    private Map<Integer, String> commentMap;    // {productId: comment}
}
