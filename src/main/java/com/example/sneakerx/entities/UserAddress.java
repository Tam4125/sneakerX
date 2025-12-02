package com.example.sneakerx.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "user_addresses")
public class UserAddress {

    @Id
    private Integer addressId;
    private Integer userId;
    private String recipientName;
    private String phone;
    private String provinceOrCity;
    private String district;
    private String ward;
    private String addressLine;
}
