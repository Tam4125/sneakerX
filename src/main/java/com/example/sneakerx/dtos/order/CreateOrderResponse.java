package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.payment.PaymentDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateOrderResponse {
    private Integer orderId;
    private Integer paymentId;
}
