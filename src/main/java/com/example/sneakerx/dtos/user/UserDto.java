package com.example.sneakerx.dtos.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserDto {
    private Integer userId;
    private String username;
    private String fullName;
    private String email;
    private String phone;
    private String role;
    private String avatarUrl;
    private String status;
    private LocalDateTime createdAt;
}
