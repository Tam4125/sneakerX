package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ShopBasicInfo {
    private Integer shopId;
    private String shopName;
    private String shopDescription;
    private String shopLogo;
    private Float rating;
    private Integer followersCount;
}
