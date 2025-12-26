package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class VariantUpdateRequest {
    private Integer variantId; // If NULL -> Create New. If PRESENT -> Update Existing.
    private String variantType;  // "SIZE" or "COLOR"
    private String variantValue; // "42", "0xFF0000"
    private Double price;
    private Integer stock;
}
