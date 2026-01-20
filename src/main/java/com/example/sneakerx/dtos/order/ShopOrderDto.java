package com.example.sneakerx.dtos.order;

import com.example.sneakerx.dtos.shop.ShopDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ShopOrderDto {
    private Integer shopOrderId;
    private Integer orderId;
    private ShopDto shop;
    private Double shippingFee;
    private Double subTotal;
    private String orderStatus;
    private String noteToSeller;
    private LocalDateTime createdAt;
    private List<OrderItemDto> orderItems;
}
