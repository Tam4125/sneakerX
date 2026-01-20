package com.example.sneakerx.dtos.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductAttributeDto {
    private Integer attributeId;
    private Integer productId;
    private String name;
    private List<AttributeValueDto> values;
}
