package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.shop.ShopDto;
import com.example.sneakerx.dtos.shop.ShopFollowerDto;
import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.ShopFollower;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ShopMapper {

    private final ProductMapper productMapper;

    public ShopFollowerDto mapToshopFollowerDto(ShopFollower shopFollower) {
        return ShopFollowerDto.builder()
                .followerId(shopFollower.getFollowerId())
                .userId(shopFollower.getUser().getUserId())
                .followedAt(shopFollower.getFollowedAt())
                .build();
    }

    public ShopDto mapToShopDto(Shop shop) {
        ShopDto shopDto = new ShopDto();
        shopDto.setShopId(shop.getShopId());
        shopDto.setShopDescription(shop.getShopDescription());
        shopDto.setShopName(shop.getShopName());
        shopDto.setShopLogo(shop.getShopLogo());
        shopDto.setRating(shop.getRating());
        shopDto.setFollowersCount(shop.getFollowersCount());
        shopDto.setCreatedAt(shop.getCreatedAt());
        shopDto.setUserId(shop.getUser().getUserId());
        if(shop.getFollowers() != null) {
            shopDto.setFollowers(shop.getFollowers().stream().map(this::mapToshopFollowerDto).toList());
        }
        if(shop.getProducts() != null) {
            shopDto.setProducts(shop.getProducts().stream().map(productMapper::mapToDetailResponse).toList());
        }

        return shopDto;
    }
}
