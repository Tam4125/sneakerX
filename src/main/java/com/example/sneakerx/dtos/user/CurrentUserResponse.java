package com.example.sneakerx.dtos.user;

import com.example.sneakerx.entities.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CurrentUserResponse {
    private Integer userId;
    private String username;
    private String email;
    private String role;
    private String avatarUrl;

    public CurrentUserResponse(User user) {
        this.userId = user.getUserId();
        this.username = user.getUsername();
        this.email = user.getEmail();
        this.role = user.getRole().toString();
        this.avatarUrl = user.getAvatarUrl();
    }
}
