package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.entities.Category;
import com.example.sneakerx.services.CategoryService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/categories")
public class CategoryController {
    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<Category>>> getCategories(
            @PageableDefault(size = 5) Pageable pageable
    ) {
        Page<Category> result = categoryService.getCategories(pageable);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get categories successfully", result));
    }
}
