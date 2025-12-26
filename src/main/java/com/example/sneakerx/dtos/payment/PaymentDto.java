package com.example.sneakerx.dtos.payment;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentDto {
    private Integer paymentId;
    private Integer orderId;
    private Integer userId;
    private Double amount;
    private String provider;
    private String paymentStatus;
    private String transactionId;
}
