package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
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
    private Integer orderId;
    private Integer shopId;
    private Integer sizeId;
    private Integer colorId;
    private Integer quantity;
    private ProductDetailResponse product;
    private Double price;
}
