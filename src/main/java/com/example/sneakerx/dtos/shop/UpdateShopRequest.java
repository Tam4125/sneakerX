package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateShopRequest {
    private Integer shopId;
    private String shopName;
    private String shopDescription;
    private String shopLogo;
}
