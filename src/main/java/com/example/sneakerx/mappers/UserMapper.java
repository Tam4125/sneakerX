package com.example.sneakerx.mappers;


import com.example.sneakerx.dtos.authentication.SignInResponse;
import com.example.sneakerx.dtos.user.UserDto;
import com.example.sneakerx.entities.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class UserMapper {
    public SignInResponse mapToSignInResponse(User user, String accessToken, String refreshToken) {
        SignInResponse response = new SignInResponse();
        response.setUserId(user.getUserId());
        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        response.setRole(user.getRole().toString());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken);

        return response;
    }

    public UserDto mapToUserDto(User user) {
        UserDto userDto = new UserDto();

        userDto.setUserId(user.getUserId());
        userDto.setUsername(user.getUsername());
        userDto.setEmail(user.getEmail());
        userDto.setRole(user.getRole().toString());
        userDto.setAvatarUrl(user.getAvatarUrl());
        userDto.setPhone(user.getPhone());
        userDto.setFullName(user.getFullName());
        userDto.setStatus(user.getStatus().toString());
        userDto.setCreatedAt(user.getCreatedAt());

        return userDto;

    }
}
