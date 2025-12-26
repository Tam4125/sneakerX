package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.payment.PaymentDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderDto {
    private Integer orderId;
    private Integer userId;
    private Integer addressId;
    private Double totalPrice;
    private Double shippingFee;
    private String orderStatus;
    private List<OrderItemDto> orderItems;
    private PaymentDto payment;

}
