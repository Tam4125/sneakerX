package com.example.sneakerx.dtos.category;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CategoryDto {
    private Integer categoryId;
    private String description;
    private String name;
    private LocalDateTime createdAt;
}
