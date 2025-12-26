package com.example.sneakerx.entities;

import com.example.sneakerx.entities.enums.CouponDiscountType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "coupons")
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer coupon_id;

    private String code;

    @Enumerated(EnumType.STRING)
    private CouponDiscountType discount_type;

    private Double discount_value;
    private Double min_order_amount;
    private Double max_discount;

    private LocalDateTime start_date;
    private LocalDateTime end_date;

}
