package com.example.sneakerx.services;

import com.example.sneakerx.dtos.SignInRequest;
import com.example.sneakerx.dtos.SignInResponse;
import com.example.sneakerx.dtos.SignUpRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.repositories.UserRepository;
import com.example.sneakerx.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    public User signUp(SignUpRequest request) throws Exception {
        if(userRepository.existsByEmail(request.getEmail())){
            throw new Exception("Email already exists");
        }
        if(userRepository.existsByUsername(request.getUsername())){
            throw new Exception("Username already exists");
        }

        User newUser = new User();
        newUser.setEmail(request.getEmail());
        newUser.setUsername(request.getUsername());
        newUser.setPasswordHash(passwordEncoder.encode(request.getPassword()));

        return userRepository.save(newUser);
    }

    public SignInResponse signIn(SignInRequest request) throws Exception{

        // Step 1 — Find user by username or email
        if(!userRepository.existsByUsername(request.getIdentifier()) && !userRepository.existsByEmail(request.getIdentifier())) {
            throw new Exception("User not found");
        }

        // Get user
        User user = new User();
        if(userRepository.existsByUsername(request.getIdentifier())) {
            user = userRepository.findByUsername(request.getIdentifier());
        }

        if(userRepository.existsByEmail(request.getIdentifier())) {
            user = userRepository.findByEmail(request.getIdentifier());
        }

        // Step 2 — Check password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new Exception("Password is incorrect");
        }

        // Step 3 — Generate JWT token
        String token = jwtUtil.generateToken(user);

        return new SignInResponse(
                user.getUserId(),
                user.getUsername(),
                user.getEmail(),
                token
        );
    }

}
