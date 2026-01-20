package com.example.sneakerx.services;

import com.example.sneakerx.dtos.category.CategoryDto;
import com.example.sneakerx.entities.Category;
import com.example.sneakerx.mappers.CategoryMapper;
import com.example.sneakerx.repositories.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {
    private final CategoryRepository categoryRepository;

    private final CategoryMapper categoryMapper;


    public List<CategoryDto> getCategories() {
        List<Category> categories = categoryRepository.findAllByOrderByCreatedAtDesc();
        return categories.stream().map(categoryMapper::toCategoryDto).toList();
    }
}
