package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateSkuRequest {
    private String skuCode;
    private Double price;
    private Integer stock;

    Map<String, String> specifications;
}
