package com.example.sneakerx.dtos.authentication;

import com.example.sneakerx.dtos.user.UserDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignInResponse {
    private UserDto user;
    private String accessToken;   // JWT
    private String refreshToken;
}
