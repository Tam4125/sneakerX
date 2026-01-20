package com.example.sneakerx.dtos.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
    public class CreateAttributeRequest {
    private String name;
    private List<CreateAttributeValueRequest> values;
}
