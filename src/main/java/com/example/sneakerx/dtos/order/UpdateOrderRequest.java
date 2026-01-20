package com.example.sneakerx.dtos.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateOrderRequest {
    private Integer orderId;
    private String paymentStatus;
}
