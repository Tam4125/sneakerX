package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateProductRequest {
    private String name;
    private String description;
    private Integer shopId;
    private Integer categoryId; // If seller choose an existing category
    private Double basePrice;

    private List<String> imageUrls;
    private List<CreateAttributeRequest> attributes;
    private List<CreateSkuRequest> skus;

}
