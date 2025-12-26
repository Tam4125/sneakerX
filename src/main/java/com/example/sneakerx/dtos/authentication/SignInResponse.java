package com.example.sneakerx.dtos.authentication;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignInResponse {
    private Integer userId;
    private String username;
    private String email;
    private String role;
    private String avatarUrl;
    private String accessToken;   // JWT
    private String refreshToken;
    private String tokenType = "Bearer";


}
