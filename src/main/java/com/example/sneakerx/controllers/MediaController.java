package com.example.sneakerx.controllers;

import com.example.sneakerx.services.CloudinaryService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/media")
public class MediaController {
    @Autowired
    private CloudinaryService cloudinaryService;

    @PostMapping("/avatar/{userId}")
    public ResponseEntity<ApiResponse<String>> uploadAvatar(
            @RequestParam(name = "file") MultipartFile file,
            @PathVariable(name = "userId") Integer userId
    ) throws IOException {
        String url = cloudinaryService.uploadUser(file, userId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Upload successfully", url));
    }
    // Endpoint 2: For Shop uploading product media
    @PostMapping("/product/{shopId}")
    public ResponseEntity<ApiResponse<String>> uploadProduct(
            @RequestParam(name = "file") MultipartFile file,
            @PathVariable(name = "shopId") Integer shopId
    ) throws IOException {
        String url = cloudinaryService.uploadProductMedia(file, shopId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Upload successfully", url));
    }
}
