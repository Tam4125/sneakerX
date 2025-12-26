package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.OrderItemDto;
import com.example.sneakerx.entities.Order;
import com.example.sneakerx.entities.OrderItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrderMapper {

    private final PaymentMapper paymentMapper;
    private final ProductMapper productMapper;

    public OrderDto mapToOderDto(Order order) {
        OrderDto orderDto = new OrderDto();
        orderDto.setOrderId(order.getOrderId());
        orderDto.setOrderStatus(order.getOrderStatus().toString());
        orderDto.setUserId(order.getUser().getUserId());
        orderDto.setTotalPrice(order.getTotalPrice());
        orderDto.setShippingFee(order.getShippingFee());
        orderDto.setAddressId(order.getUserAddress().getAddressId());
        orderDto.setOrderItems(
                order.getOrderItems().stream().map(
                        this::mapToOrderItemDto
                ).toList()
        );
        orderDto.setPayment(paymentMapper.mapToPaymentDto(order.getPayment()));

        return orderDto;
    }

    public OrderItemDto mapToOrderItemDto(OrderItem orderItem) {
        OrderItemDto orderItemDto = new OrderItemDto();
        orderItemDto.setOrderItemId(orderItem.getOrderItemId());
        orderItemDto.setOrderId(orderItem.getOrder().getOrderId());
        orderItemDto.setSizeId(orderItem.getSizeId());
        orderItemDto.setShopId(orderItem.getShop().getShopId());
        orderItemDto.setColorId(orderItem.getColorId());
        orderItemDto.setQuantity(orderItem.getQuantity());
        orderItemDto.setProduct(productMapper.mapToDetailResponse(orderItem.getProduct()));
        orderItemDto.setPrice(orderItem.getPrice());

        return orderItemDto;
    }
}
