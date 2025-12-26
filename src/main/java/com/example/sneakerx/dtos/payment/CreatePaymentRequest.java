package com.example.sneakerx.dtos.payment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreatePaymentRequest {
    private Integer orderId;
    private Integer userId;
    private Double amount;
    private String provider;
    private String paymentStatus;
    private String transactionId;
}
