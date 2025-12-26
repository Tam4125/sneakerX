package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.payment.StripePaymentRequest;
import com.example.sneakerx.dtos.payment.StripePaymentResponse;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.PaymentService;
import com.example.sneakerx.utils.ApiResponse;
import com.stripe.exception.StripeException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.file.AccessDeniedException;

@RestController
@RequestMapping("/payments")
public class PaymentController {
    @Autowired
    private PaymentService paymentService;


    @PostMapping("/create/stripe-intent")
    public ResponseEntity<ApiResponse<StripePaymentResponse>> createStripeIntent(
            @AuthenticationPrincipal User user,
            @RequestBody StripePaymentRequest request
    ) throws StripeException, AccessDeniedException {
        StripePaymentResponse response = paymentService.createStripeIntent(request, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create stripe payment intent successfully", response));
    }
}
