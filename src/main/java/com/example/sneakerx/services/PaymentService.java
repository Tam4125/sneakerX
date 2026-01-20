package com.example.sneakerx.services;

import com.example.sneakerx.dtos.payment.*;
import com.example.sneakerx.entities.Order;
import com.example.sneakerx.entities.Payment;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.entities.enums.PaymentStatus;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.PaymentMapper;
import com.example.sneakerx.repositories.OrderRepository;
import com.example.sneakerx.repositories.PaymentRepository;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final OrderRepository orderRepository;
    private final PaymentMapper paymentMapper;
    private final PaymentRepository paymentRepository;

    @Transactional
    public PaymentDto updatePaymentStatus(UpdatePaymentRequest request, Integer paymentId, User user) throws AccessDeniedException {
        Payment payment = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));

        if(!user.getUserId().equals(payment.getUser().getUserId()) || !request.getPaymentId().equals(paymentId)) {
            throw new AccessDeniedException("Forbidden");
        }

        payment.setPaymentStatus(PaymentStatus.valueOf(request.getPaymentStatus()));

        if(PaymentStatus.valueOf(request.getPaymentStatus()) == PaymentStatus.PAID) {
            payment.setPaidAt(LocalDateTime.now());
            Order order = payment.getOrder();
            order.setPaymentStatus(PaymentStatus.PAID);
            orderRepository.save(order);
        }

        if(PaymentStatus.valueOf(request.getPaymentStatus()) == PaymentStatus.REFUNDED) {
            Order order = payment.getOrder();
            order.setPaymentStatus(PaymentStatus.REFUNDED);
            orderRepository.save(order);
        }

        Payment savedPayment = paymentRepository.save(payment);

        return paymentMapper.toPaymentDto(savedPayment);
    }

    public StripePaymentResponse createStripeIntent(StripePaymentRequest request, User user) throws StripeException, AccessDeniedException {
        if(!request.getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }


        // 1. Build the payment parameters
        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(request.getAmount())
                .setCurrency(request.getCurrency())
                .setReceiptEmail(request.getUserEmail())
                // "automatic" allows Stripe to decide best payment methods (Card, Apple Pay, etc.)
                .setAutomaticPaymentMethods(
                        PaymentIntentCreateParams.AutomaticPaymentMethods.builder()
                                .setEnabled(true)
                                .build()
                )
                .build();

        // 2. Call Stripe API
        PaymentIntent intent = PaymentIntent.create(params);
        return new StripePaymentResponse(intent.getClientSecret(), intent.getId());
    }
}
