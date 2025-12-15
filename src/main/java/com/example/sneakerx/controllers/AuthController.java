package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.SignInRequest;
import com.example.sneakerx.dtos.SignInResponse;
import com.example.sneakerx.dtos.SignUpRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.repositories.EmailVerificationTokenRepository;
import com.example.sneakerx.repositories.UserRepository;
import com.example.sneakerx.services.AuthService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailVerificationTokenRepository emailVerificationTokenRepository;

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
                    .status(HttpStatus.OK)
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

    @GetMapping("/verify")
    public ResponseEntity<ApiResponse<User>> verifyAccount(
            @RequestParam String token
    ) {
        try {
            User user = authService.verifyAccount(token);
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(ApiResponse.ok("Verified successfully", user));

        } catch (Exception e) {
            ApiResponse<User> errorResponse = new ApiResponse<>(
                    false,
                    e.getMessage()
            );

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(errorResponse);
        }
    }
}
