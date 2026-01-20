package com.example.sneakerx.controllers;

import com.example.sneakerx.services.CloudinaryService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/media")
@RequiredArgsConstructor
public class MediaController {
    private final CloudinaryService cloudinaryService;

    @PostMapping("/users/{userId}")
    public ResponseEntity<ApiResponse<String>> uploadUserAvatar(
            @RequestPart("avatarImage") MultipartFile avatarImage,
            @PathVariable(name = "userId") Integer userId
    ) throws IOException {
        String url = cloudinaryService.uploadUser(avatarImage, userId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Upload successfully", url));
    }

    @PostMapping("/shops/{shopId}")
    public ResponseEntity<ApiResponse<String>> uploadShopAvatar(
            @RequestPart("avatarImage") MultipartFile avatarImage,
            @PathVariable(name = "shopId") Integer shopId
    ) throws IOException {
        String url = cloudinaryService.uploadShop(avatarImage, shopId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Upload successfully", url));
    }

    // Endpoint 2: For Shop uploading product media
    @PostMapping("/products")
    public ResponseEntity<ApiResponse<List<String>>> uploadProduct(
            @RequestParam("shopId") Integer shopId,
            @RequestParam("productId") Integer productId,
            @RequestPart("images") List<MultipartFile> images
    ) throws IOException {
        List<String> urls = cloudinaryService.uploadProductMedia(images, shopId, productId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Upload successfully", urls));
    }
}
