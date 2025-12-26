package com.example.sneakerx.services;

import com.example.sneakerx.dtos.authentication.SignInRequest;
import com.example.sneakerx.dtos.authentication.SignInResponse;
import com.example.sneakerx.dtos.authentication.SignUpRequest;
import com.example.sneakerx.entities.Cart;
import com.example.sneakerx.entities.RefreshToken;
import com.example.sneakerx.entities.EmailVerificationToken;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.entities.enums.UserRole;
import com.example.sneakerx.entities.enums.UserStatus;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.UserMapper;
import com.example.sneakerx.repositories.CartRepository;
import com.example.sneakerx.repositories.RefreshTokenRepository;
import com.example.sneakerx.repositories.EmailVerificationTokenRepository;
import com.example.sneakerx.repositories.UserRepository;
import com.example.sneakerx.utils.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final EmailVerificationTokenRepository emailVerificationTokenRepository;
    private final EmailService emailService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserMapper userMapper;
    private final CartRepository cartRepository;

    public User signUp(SignUpRequest request) throws Exception {
        if(userRepository.existsByEmail(request.getEmail())){
            throw new Exception("Email already exists");
        }
        if(userRepository.existsByPhone(request.getPhone())){
            throw new Exception("Phone number already exists");
        }
        if(userRepository.existsByUsername(request.getUsername())){
            throw new Exception("Username already exists");
        }

        User newUser = new User();
        newUser.setEmail(request.getEmail());
        newUser.setUsername(request.getUsername());
        newUser.setPhone(request.getPhone());
        newUser.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        newUser.setAvatarUrl(request.getAvatarUrl());
        newUser.setRole(UserRole.BUYER);
        newUser.setStatus(UserStatus.ACTIVE);
        newUser.setEnabled(false);

        userRepository.save(newUser);

        // Create default cart
        Cart newCart = new Cart();
        newCart.setUser(newUser);
        cartRepository.save(newCart);

        // Email verification
        String token = UUID.randomUUID().toString();
        EmailVerificationToken newEmailVerificationToken = new EmailVerificationToken();
        newEmailVerificationToken.setToken(token);
        newEmailVerificationToken.setUserId(newUser.getUserId());
        newEmailVerificationToken.setExpiryDate(LocalDateTime.now().plusMinutes(30));

        emailVerificationTokenRepository.save(newEmailVerificationToken);

        emailService.sendVerificationEmail(newUser.getEmail(), token);

        return newUser;
    }

    public User verifyAccount(String token) throws Exception {
        EmailVerificationToken emailVerificationToken = emailVerificationTokenRepository.findByToken(token)
                .orElseThrow(() -> new Exception("Invalid token"));

        if(emailVerificationToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new Exception("Token expired");
        }

        User user = userRepository.findById(emailVerificationToken.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setEnabled(true);
        userRepository.save(user);

        emailVerificationTokenRepository.delete(emailVerificationToken);

        return user;
    }

    public SignInResponse signIn(SignInRequest request) throws Exception {

        // Step 1 — Find user by username or email
        User user = userRepository.findByUsername(request.getIdentifier())
                .or(() -> userRepository.findByEmail(request.getIdentifier()))
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));



        // Step 2 — Check password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Password is incorrect");
        }

        // Check if enabled (Optional, depending on your flow)
        if (!user.isEnabled()) {

            String token = UUID.randomUUID().toString();
            EmailVerificationToken newEmailVerificationToken = new EmailVerificationToken();
            newEmailVerificationToken.setToken(token);
            newEmailVerificationToken.setUserId(user.getUserId());
            newEmailVerificationToken.setExpiryDate(LocalDateTime.now().plusMinutes(30));

            emailVerificationTokenRepository.save(newEmailVerificationToken);

            emailService.sendVerificationEmail(user.getEmail(), token);

            throw new Exception("Account not verified. Please check your email.");
        }

        // Step 3 — Generate JWT token
        String accessToken = jwtUtil.generateToken(user);
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(LocalDateTime.now().plusDays(30))
                .build();

        refreshTokenRepository.save(refreshToken);

        return userMapper.mapToSignInResponse(user, accessToken, refreshToken.getToken());
    }

    // REFRESH TOKEN (Get new Access Token)
    public SignInResponse refreshToken(String refreshToken) throws Exception {
        // Find token in DB
        RefreshToken storedToken = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> new Exception("Refresh token is not in database!"));

        // Check Expiry
        if(storedToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(storedToken);
            throw new Exception("Refresh token was expired. Please make a new signin request");
        }

        // Generate NEW Access Token
        User user = storedToken.getUser();
        String newAccessToken = jwtUtil.generateToken(user);
        return userMapper.mapToSignInResponse(user, newAccessToken, refreshToken);
    }

    // SIGN OUT (Kill the session)
    public void signOut(String refreshtoken) {
        refreshTokenRepository.findByToken(refreshtoken).ifPresent(refreshTokenRepository::delete);
    }
}
