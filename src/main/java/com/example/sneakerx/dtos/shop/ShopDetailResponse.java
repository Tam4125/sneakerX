package com.example.sneakerx.dtos.shop;

import com.example.sneakerx.dtos.order.ShopOrderDto;
import com.example.sneakerx.dtos.product.ProductDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShopDetailResponse {
    private ShopDto shop;
    private List<ShopOrderDto> shopOrders;
    private List<ProductDto> products;
    private List<ShopFollowerDto> followers;
}
