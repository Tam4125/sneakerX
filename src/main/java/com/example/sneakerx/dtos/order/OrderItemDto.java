package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.product.ProductDto;
import com.example.sneakerx.dtos.product.ProductSkuDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemDto {
    private Integer orderItemId;
    private Integer shopOrderId;
    private ProductDto product;
    private ProductSkuDto sku;
    private String productNameSnapshot;
    private String skuNameSnapshot;
    private Double priceAtPurchase;
    private Integer quantity;
}

