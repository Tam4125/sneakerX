package com.example.sneakerx.dtos.product;

import com.example.sneakerx.entities.enums.VariantType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductVariantResponse {
    private Integer variantId;
    private String variantType;
    private String variantValue;
    private Double price;
    private Integer stock;

}
