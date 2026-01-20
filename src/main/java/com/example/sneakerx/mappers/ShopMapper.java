package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.shop.ShopDto;
import com.example.sneakerx.dtos.shop.ShopFollowerDto;
import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.ShopFollower;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {UserMapper.class})
public interface ShopMapper {
    @Mapping(source = "user.userId", target = "userId")
    ShopDto toShopDto(Shop shop);

    @Mapping(source = "shop", target = "shop")
    @Mapping(source = "user", target = "user")
    ShopFollowerDto toShopFollowerDto(ShopFollower shopFollower);

}
