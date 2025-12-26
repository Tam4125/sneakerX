package com.example.sneakerx.dtos.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UpdateUserRequest {
    private Integer userId;
    private String username;
    private String fullName;
    private String email;
    private String phone;
    private String status;
    private MultipartFile avatar;
}
