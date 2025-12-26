package com.example.sneakerx.dtos.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateOrderRequest {
    private Integer addressId;
    private Double shippingFee;
    private List<Integer> cartItems;

    private String provider;
    private String transactionId;
    private String orderStatus;
}
