package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttributeValueDto {
    private Integer valueId;
    private Integer attributeId;
    private String value;
    private String imageUrl;
}
