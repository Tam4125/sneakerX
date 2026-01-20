package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.ShopOrderDto;
import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.product.ProductDto;
import com.example.sneakerx.dtos.shop.*;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.mappers.ShopMapper;
import com.example.sneakerx.repositories.ShopRepository;
import com.example.sneakerx.services.ShopService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;
import java.util.List;


@RestController
@RequestMapping("/shops")
@RequiredArgsConstructor
public class ShopController {
    private final ShopService shopService;

    private final ShopRepository shopRepository;

    private final ShopMapper shopMapper;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ShopDetailResponse>> getCurrentUserShop(
            @AuthenticationPrincipal User user
    ) {
        ShopDetailResponse currentShop = shopService.getCurrentUserShop(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Current shop data retrieved successfully", currentShop));
    }

    @GetMapping("/me/orders")
    public ResponseEntity<ApiResponse<List<ShopOrderDto>>> getOrders(
            @AuthenticationPrincipal User user
    ) {
        List<ShopOrderDto> shopOrders = shopService.getShopOrders(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get shop orders successfully", shopOrders));

    }

    @GetMapping("/{shopId}")
    public ResponseEntity<ApiResponse<ShopDetailResponse>> getShopById(
            @PathVariable(name = "shopId") Integer shopId
    ) {
        ShopDetailResponse shop = shopService.getShopById(shopId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get shop information successfully", shop));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ShopDto>> createShop(
            @AuthenticationPrincipal User user,
            @RequestBody CreateShopRequest request
    ) {
        ShopDto shopDto = shopService.createShop(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create shop successfully", shopDto));
    }

    @PutMapping("/{shopId}")
    public ResponseEntity<ApiResponse<ShopDto>> updateShop(
            @PathVariable(name = "shopId") Integer shopId,
            @RequestBody UpdateShopRequest request,
            @AuthenticationPrincipal User user
    ) {
        ShopDto shopDto = shopService.updateShop(request);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Edit shop information successfully", shopDto));
    }


    @PostMapping("/products")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> createProduct(
            @AuthenticationPrincipal User user,
            @RequestBody CreateProductRequest request
    ) throws AccessDeniedException {

        ProductDetailResponse product = shopService.createProduct(request, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create product successfully", product));
    }

    @PutMapping("/products/{productId}")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> updateProduct(
            @PathVariable Integer productId,
            @AuthenticationPrincipal User user,
            @RequestBody UpdateProductRequest request
    ) throws AccessDeniedException {

        ProductDetailResponse product = shopService.updateProduct(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update product successfully", product));
    }


}
