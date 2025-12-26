package com.example.sneakerx.config;

import com.example.sneakerx.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

@Configuration
@RequiredArgsConstructor
public class ApplicationConfig {
    private final UserRepository userRepository;

    @Bean
    public UserDetailsService userDetailsService() {
        return userId -> userRepository.findByUserId(Integer.parseInt(userId))
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

    }
}
