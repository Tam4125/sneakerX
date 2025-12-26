package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.payment.PaymentDto;
import com.example.sneakerx.entities.Payment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PaymentMapper {
    public PaymentDto mapToPaymentDto(Payment payment) {
        PaymentDto paymentDto = new PaymentDto();
        paymentDto.setAmount(payment.getAmount());
        paymentDto.setPaymentId(payment.getPaymentId());
        paymentDto.setPaymentStatus(payment.getPaymentStatus().toString());
        paymentDto.setProvider(payment.getProvider().toString());
        paymentDto.setOrderId(payment.getOrder().getOrderId());
        paymentDto.setUserId(payment.getUser().getUserId());
        paymentDto.setTransactionId(payment.getTransactionId());

        return paymentDto;
    }
}
