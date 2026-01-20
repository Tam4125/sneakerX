package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.payment.PaymentDto;
import com.example.sneakerx.entities.customClasses.AddressSnapshot;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderDto {
    private Integer orderId;
    private Integer userId;
    private List<PaymentDto> payments;
    private AddressSnapshot shippingAddress;
    private Double totalAmount;
    private String paymentStatus;
    private LocalDateTime createdAt;
    private List<ShopOrderDto> shopOrders;
}

