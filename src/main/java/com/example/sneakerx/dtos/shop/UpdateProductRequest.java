package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateProductRequest {
    private Integer productId;
    private String name;
    private String description;
    private Integer shopId;
    private Integer categoryId; // If seller choose an existing category
    private Double basePrice;

    private List<Integer> keepImages;
    private List<String> newImageUrls;

    private Map<Integer, List<Integer>> keepAttributesKeepValues;
    private Map<Integer, List<CreateAttributeValueRequest>> keepAttributesNewValues;
    private List<CreateAttributeRequest> newAttributes;

    private List<UpdateSkuRequest> existingSkus;
    private List<CreateSkuRequest> newSkus;
}
