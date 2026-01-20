package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.product.*;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.ProductService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<ProductDto>>> searchProducts(
            @RequestParam(name = "q", required = false) String q,
            @RequestParam(name = "categoryId", required = false) Integer categoryId,
            @RequestParam(name = "minPrice", required = false) Double minPrice,
            @RequestParam(name = "maxPrice", required = false) Double maxPrice,
            Pageable pageable
    ) {
        ProductSearchRequest request = new ProductSearchRequest();
        request.setQ(q);
        request.setCategoryId(categoryId);
        request.setMinPrice(minPrice);
        request.setMaxPrice(maxPrice);

        Page<ProductDto> result = productService.search(request, pageable);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Search successfully", result));
    }

    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<Page<ProductDto>>> getPopularProduct(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Page<ProductDto> popularProducts = productService.getPopularProducts(page, size);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get popular products successfully", popularProducts));
    }

    @GetMapping("/favourite")
    public ResponseEntity<ApiResponse<Page<ProductDto>>> getFavouriteProduct(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Page<ProductDto> favouriteProducts = productService.getFavouriteProducts(page, size);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get favourite products successfully", favouriteProducts));
    }

    @GetMapping("/attributes/popular")
    public ResponseEntity<ApiResponse<Page<ProductAttributeDto>>> getPopularAttributes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Page<ProductAttributeDto> productAttributes = productService.getPopularAttribute(page, size);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get popular attributes successfully", productAttributes));
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> getProductDetail(
            @PathVariable(name = "productId") Integer productId
    ) {
        ProductDetailResponse productDetail = productService.getProductDetail(productId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get product id {" + productId + "} successfully", productDetail));
    }

    @PostMapping("/reviews")
    public ResponseEntity<ApiResponse<List<ProductReviewDto>>> createReview(
            @AuthenticationPrincipal User user,
            @RequestBody CreateReviewRequest request
    ) {
        List<ProductReviewDto> reviews = productService.createReviews(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create review successfully", reviews));
    }
}
