package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.payment.PaymentDto;
import com.example.sneakerx.dtos.payment.StripePaymentRequest;
import com.example.sneakerx.dtos.payment.StripePaymentResponse;
import com.example.sneakerx.dtos.payment.UpdatePaymentRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.PaymentService;
import com.example.sneakerx.utils.ApiResponse;
import com.stripe.exception.StripeException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PutMapping("{paymentId}")
    public ResponseEntity<ApiResponse<PaymentDto>> updatePaymentStatus(
            @AuthenticationPrincipal User user,
            @RequestBody UpdatePaymentRequest request,
            @PathVariable(name = "paymentId") Integer paymentId
    ) throws AccessDeniedException {
        PaymentDto payment = paymentService.updatePaymentStatus(request, paymentId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update payment status successfully", payment));
    }


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
