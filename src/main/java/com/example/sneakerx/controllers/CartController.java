package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.cart.CartResponse;
import com.example.sneakerx.dtos.cart.SaveToCartRequest;
import com.example.sneakerx.dtos.cart.UpdateCartRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.CartService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;

@RestController
@RequestMapping("/carts")
@RequiredArgsConstructor
public class CartController {
    private final CartService cartService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<CartResponse>> getCurrentUserCart(
            @AuthenticationPrincipal User user
    ) {
        CartResponse cart = cartService.getCurrentUserCart(user);
        return ResponseEntity
                .status(HttpStatus.OK)
                    .body(ApiResponse.ok("Get current user cart successfully", cart));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<CartResponse>> updateCart(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateCartRequest request
    ) {
        CartResponse cart = cartService.updateCart(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update cart successfully", cart));
    }

    @PostMapping("/items")
    public ResponseEntity<ApiResponse<CartResponse>> saveToCart(
            @AuthenticationPrincipal User user,
            @RequestBody SaveToCartRequest request
    ) {
        CartResponse cart = cartService.saveToCart(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Save product to cart successfully", cart));
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<ApiResponse<CartResponse>> deleteCartItem(
            @PathVariable(name = "itemId") Integer itemId,
            @AuthenticationPrincipal User user
    ) throws AccessDeniedException {
        CartResponse cart = cartService.deleteCartItem(itemId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Successfully delete cart item id " + itemId, cart));
    }
}
