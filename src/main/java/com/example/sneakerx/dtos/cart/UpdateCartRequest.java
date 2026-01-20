package com.example.sneakerx.dtos.cart;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UpdateCartRequest {
    private Map<Integer, Integer> updatedQuantities;
}
