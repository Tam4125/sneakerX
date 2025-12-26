package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.OrderItemDto;
import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.shop.*;
import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.mappers.ShopMapper;
import com.example.sneakerx.repositories.ShopRepository;
import com.example.sneakerx.services.ShopService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/shops")
public class ShopController {
    @Autowired
    private ShopService shopService;

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private ShopMapper shopMapper;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ShopDto>> getCurrentUserShop(
            @AuthenticationPrincipal User user
    ) {
        Optional<Shop> currentShop = shopRepository.findByUser(user);

        if(currentShop.isPresent()) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(ApiResponse.ok("Current shop data retrieved successfully", shopMapper.mapToShopDto(currentShop.get())));
        } else {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(ApiResponse.ok("User does not have a shop yet", null));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ShopDto>> createShop(
            @AuthenticationPrincipal User user,
            @ModelAttribute CreateShopRequest request
    ) throws IOException {
        ShopDto shopDto = shopService.createShop(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create shop successfully", shopDto));
    }

    @GetMapping("/{shopId}")
    public ResponseEntity<ApiResponse<ShopDto>> getShopDetail(
            @PathVariable(name = "shopId") Integer shopId
    ) {
        ShopDto shopDto = shopService.getShopById(shopId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get shop information successfully", shopDto));
    }

    @PostMapping("/product")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> createProduct(
            @AuthenticationPrincipal User user,
            @RequestPart("data") String productDataJson,
            @RequestPart(value = "images", required = false) List<MultipartFile> images
    ) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        CreateProductRequest request = mapper.readValue(productDataJson, CreateProductRequest.class);

        ProductDetailResponse productDetailResponse = shopService.createProduct(request, images, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create  successfully", productDetailResponse));
    }

    @PutMapping("/product/{productId}")
    public ResponseEntity<ApiResponse<ProductDetailResponse>> updateProduct(
            @PathVariable Integer productId,
            @AuthenticationPrincipal User user,
            @RequestPart("data") String productDataJson,
            @RequestPart(value = "newImages", required = false) List<MultipartFile> newImages

    ) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        UpdateProductRequest request = mapper.readValue(productDataJson, UpdateProductRequest.class);

        ProductDetailResponse productDetailResponse = shopService.updateProduct(productId, request, newImages, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update product successfully", productDetailResponse));
    }

    @GetMapping("/{shopId}/orderItems")
    public ResponseEntity<ApiResponse<List<OrderItemDto>>> getOrderItems(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "shopId") Integer shopId
    ) {
        List<OrderItemDto> orderItemDtos = shopService.getAllOrderItems(shopId);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get orders by shop successfully", orderItemDtos));

    }

    @GetMapping("/{shopId}/orders")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "shopId") Integer shopId
    ) {
        List<OrderDto> orderDtos = shopService.getAllOrders(shopId);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get orders by shop successfully", orderDtos));

    }

    @PutMapping("/{shopId}")
    public ResponseEntity<ApiResponse<ShopDto>> updateShop(
            @PathVariable(name = "shopId") Integer shopId,
            @ModelAttribute UpdateShopRequest request,
            @AuthenticationPrincipal User user
    ) throws IOException {
        ShopDto shopDto = shopService.updateShop(request);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Edit shop information successfully", shopDto));
    }

}
