package com.example.sneakerx.dtos.payment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StripePaymentRequest {
    private Integer userId;
    private Long amount;
    private String currency;
    private String userEmail; // For sending receipts
}
