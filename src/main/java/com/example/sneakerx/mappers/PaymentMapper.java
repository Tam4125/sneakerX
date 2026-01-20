package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.payment.PaymentDto;
import com.example.sneakerx.entities.Payment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface PaymentMapper {
    @Mapping(source = "order.orderId", target = "orderId")
    @Mapping(source = "user.userId", target = "userId")
    PaymentDto toPaymentDto(Payment payment);
}
