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
    private Integer shopId;
    private Integer addressId;
    private Double totalPrice;
    private Double shippingFee;
}
