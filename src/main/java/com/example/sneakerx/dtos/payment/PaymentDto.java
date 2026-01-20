package com.example.sneakerx.dtos.payment;

import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentDto {
    private Integer paymentId;
    private Integer orderId;
    private Integer userId;
    private Double amount;
    private String paymentMethod;
    private String paymentStatus;
    private String transactionId;
    private LocalDateTime createdAt;
}
