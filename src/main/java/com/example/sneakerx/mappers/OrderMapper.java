package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.OrderItemDto;
import com.example.sneakerx.dtos.order.ShopOrderDto;
import com.example.sneakerx.entities.Order;
import com.example.sneakerx.entities.OrderItem;
import com.example.sneakerx.entities.ShopOrder;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {PaymentMapper.class, ShopMapper.class, ProductMapper.class}
)
public interface OrderMapper {

    @Mapping(source = "shopOrder.shopOrderId", target = "shopOrderId")
    @Mapping(source = "product", target = "product")
    OrderItemDto toOrderItemDto (OrderItem orderItem);

    @Mapping(source = "order.orderId", target = "orderId")
    @Mapping(source = "orderItems", target = "orderItems")
    ShopOrderDto toShopOrderDto(ShopOrder shopOrder);

    @Mapping(source = "user.userId", target = "userId")
    @Mapping(source = "payments", target = "payments")
    @Mapping(source = "shopOrders", target = "shopOrders")
    OrderDto toOrderDto(Order order);
}
