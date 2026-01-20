package com.example.sneakerx.dtos.product;

import lombok.*;

import java.util.List;
import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductSkuDto {
    private Integer skuId;
    private Integer productId;
    private String skuCode;
    private Double price;
    private Integer stock;
    private Integer soldCount;

    private List<AttributeValueDto> values;
}
