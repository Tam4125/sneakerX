package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.category.CategoryDto;
import com.example.sneakerx.entities.Category;
import org.mapstruct.Mapper;

@Mapper(
        componentModel = "spring"
)
public interface CategoryMapper {
    CategoryDto toCategoryDto (Category category);
}
