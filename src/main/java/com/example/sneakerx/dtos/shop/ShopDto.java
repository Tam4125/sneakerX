package com.example.sneakerx.dtos.shop;

import com.example.sneakerx.dtos.order.ShopOrderDto;
import com.example.sneakerx.dtos.product.ProductDto;
import com.example.sneakerx.entities.ShopOrder;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ShopDto {
    private Integer shopId;
    private Integer userId;
    private String shopName;
    private String shopDescription;
    private String shopLogo;
    private Float rating;
    private Integer followersCount;
    private LocalDateTime createdAt;
}
