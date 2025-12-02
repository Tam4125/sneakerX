package com.example.sneakerx.dtos;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class SignInResponse {
    private Integer userId;
    private String username;
    private String email;
    private String role;
    private String accessToken;   // JWT
    private String tokenType = "Bearer";

    public SignInResponse(Integer userId, String username, String email, String token) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.accessToken = token;
    }

}
