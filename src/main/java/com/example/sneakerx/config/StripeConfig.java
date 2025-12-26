package com.example.sneakerx.config;

import com.stripe.Stripe;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StripeConfig {

    @Value("${stripe.api.key}")
    private String secretKey;

    @PostConstruct
    public void init() {
        // Initialize Stripe with your Secret Key
        Stripe.apiKey = secretKey;
    }
}
