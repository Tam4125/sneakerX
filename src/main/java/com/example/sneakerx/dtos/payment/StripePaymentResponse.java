package com.example.sneakerx.dtos.payment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class StripePaymentResponse {
    private String clientSecret; // The "Ticket" Flutter needs
    private String transactionId;
}
