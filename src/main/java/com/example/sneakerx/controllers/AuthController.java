package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.SignInRequest;
import com.example.sneakerx.dtos.SignInResponse;
import com.example.sneakerx.dtos.SignUpRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.AuthService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/sign-up")
    public ResponseEntity<ApiResponse<User>> signUp(
            @RequestBody SignUpRequest request
    ) {
        try {
            User user = authService.signUp(request);

            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Account created successfully", user));

        } catch(Exception e) {
            ApiResponse<User> errorResponse = new ApiResponse<>(
                    false,
                    e.getMessage()
            );

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(errorResponse);
        }
    }

    @PostMapping("/sign-in")
    public ResponseEntity<ApiResponse<SignInResponse>> signIn(
            @RequestBody SignInRequest request
    ) {
        try {
            SignInResponse signInResponse = authService.signIn(request);
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Signed in successfully", signInResponse));

        } catch (Exception e) {
            ApiResponse<SignInResponse> errorResponse = new ApiResponse<>(
                    false,
                    e.getMessage()
            );

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(errorResponse);
        }
    }
}
