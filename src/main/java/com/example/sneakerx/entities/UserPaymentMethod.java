package com.example.sneakerx.entities;

import com.example.sneakerx.entities.enums.PaymentType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_payment_methods")
public class UserPaymentMethod {

    @Id
    private Integer paymentId;

    private Integer userId;

    @Enumerated(EnumType.STRING)
    private PaymentType type;

    private String provider;
    private String accountNumberMask;
    private Boolean isDefault;
    private LocalDateTime createdAt;

}
