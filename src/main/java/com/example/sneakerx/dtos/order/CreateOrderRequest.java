package com.example.sneakerx.dtos.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateOrderRequest {
    private Integer addressId;
    private Map<Integer, String> noteMap;  // {shopId: note}

    private Map<Integer, List<Integer>> itemMap;    // {shopId: list of cartItemId}
    private Map<Integer, Double> shippingFeeMap;    //{shopId: shipping fee}
    private Map<Integer, Double> subTotalMap;   //{shopId: subTotal}
    private Double totalAmount;

    private String paymentMethod;
    private String transactionId;
    private String paymentStatus;
}
