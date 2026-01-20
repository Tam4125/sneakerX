package com.example.sneakerx.entities.customClasses;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AddressSnapshot {
    private String recipientName;
    private String phone;
    private String provinceOrCity;
    private String district;
    private String ward;
    private String addressLine;
}
