package com.example.sneakerx.dtos.shop;

import lombok.Data;

@Data
public class UpdateSkuRequest {
    private Integer skuId;
    private Double price;
    private Integer stock;
}
