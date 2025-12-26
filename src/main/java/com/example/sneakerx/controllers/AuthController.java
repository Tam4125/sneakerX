package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.authentication.RefreshTokenRequest;
import com.example.sneakerx.dtos.authentication.SignInRequest;
import com.example.sneakerx.dtos.authentication.SignInResponse;
import com.example.sneakerx.dtos.authentication.SignUpRequest;
import com.example.sneakerx.dtos.user.CurrentUserResponse;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.repositories.EmailVerificationTokenRepository;
import com.example.sneakerx.repositories.UserRepository;
import com.example.sneakerx.services.AuthService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    private final UserRepository userRepository;

    private final EmailVerificationTokenRepository emailVerificationTokenRepository;

    @PostMapping("/sign-up")
    public ResponseEntity<ApiResponse<String>> signUp(
            @RequestBody SignUpRequest request
    ) throws Exception {
        User user = authService.signUp(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Account created successfully", "Sign up successfully"));
    }

    @PostMapping("/sign-in")
    public ResponseEntity<ApiResponse<SignInResponse>> signIn(
            @RequestBody SignInRequest request
    ) throws Exception {
        SignInResponse signInResponse = authService.signIn(request);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Signed in successfully", signInResponse));
    }

    @GetMapping("/verify")
    public ResponseEntity<ApiResponse<User>> verifyAccount(
            @RequestParam("token") String token
    ) throws Exception {
        User user = authService.verifyAccount(token);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Verified successfully", user));
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<ApiResponse<SignInResponse>> refreshToken(
            @RequestBody RefreshTokenRequest request
    ) throws Exception {
        SignInResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Fresh token successfully", response));
    }

    @PostMapping("/sign-out")
    public ResponseEntity<ApiResponse<String>> signOut(
            @RequestBody RefreshTokenRequest request
    ) {
        authService.signOut(request.getRefreshToken());
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Sign out successfully", ""));
    }
}
