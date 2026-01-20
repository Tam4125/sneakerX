package com.example.sneakerx.dtos.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UpdateAddressRequest {
    private Integer addressId;
    private String recipientName;
    private String phone;
    private String provinceOrCity;
    private String district;
    private String ward;
    private String addressLine;
    private Boolean isDefault;
}
