package com.example.sneakerx.dtos.shop;

import com.example.sneakerx.dtos.user.UserDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ShopFollowerDto {
    private Integer followerId;
    private UserDto user;
    private ShopDto shop;
    private LocalDateTime followedAt;
}
