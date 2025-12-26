package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.product.ProductSearchRequest;
import com.example.sneakerx.services.ProductService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/products")
public class ProductController {
    @Autowired
    private ProductService productService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<ProductDetailResponse>>> searchProducts(
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

        Page<ProductDetailResponse> result = productService.search(request, pageable);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Search successfully", result));
    }

    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<Page<ProductDetailResponse>>> getPopularProduct(@PageableDefault(size=10) Pageable pageable) {
        Page<ProductDetailResponse> popularProducts = productService.getPopularProducts(pageable);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get popular products successfull", popularProducts));
    }

    @GetMapping("/favourite")
    public ResponseEntity<ApiResponse<Page<ProductDetailResponse>>> getFavouriteProduct(@PageableDefault(size=10) Pageable pageable) {
        Page<ProductDetailResponse> favouriteProducts = productService.getFavouriteProducts(pageable);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get favourite products successfull", favouriteProducts));
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> getProductDetail(
            @PathVariable(name = "productId") Integer productId
    ) throws Exception {
        ProductDetailResponse productDetail = productService.getProductDetail(productId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get product id: " + productId + " successfully", productDetail));
    }
}
