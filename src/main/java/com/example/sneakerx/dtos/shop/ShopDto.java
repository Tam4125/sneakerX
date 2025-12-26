package com.example.sneakerx.dtos.shop;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.ShopFollower;
import com.example.sneakerx.entities.User;
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

    private List<ShopFollowerDto> followers;
    private List<ProductDetailResponse> products;

}
