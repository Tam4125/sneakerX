package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.category.CategoryDto;
import com.example.sneakerx.entities.Category;
import com.example.sneakerx.services.CategoryService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/categories")
public class CategoryController {
    @Autowired
    private CategoryService categoryService;

    @GetMapping()
    public ResponseEntity<ApiResponse<List<CategoryDto>>> getCategories() {
        List<CategoryDto> pageCategory = categoryService.getCategories();

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get categories successfully", pageCategory));
    }
}
