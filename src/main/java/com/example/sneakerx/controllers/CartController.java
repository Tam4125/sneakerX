package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.cart.CartDto;
import com.example.sneakerx.dtos.cart.SaveToCartRequest;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.CartService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;

@RestController
@RequestMapping("/carts")
public class CartController {
    @Autowired
    private CartService cartService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<CartDto>> getCurrentUserCart(
            @AuthenticationPrincipal User user
    ) {
        CartDto cartDto = cartService.getCurrentUserCart(user);
        return ResponseEntity
                .status(HttpStatus.OK)
                    .body(ApiResponse.ok("Get current user cart successfully", cartDto));
    }

    @PostMapping("/items")
    public ResponseEntity<ApiResponse<CartDto>> saveToCart(
            @AuthenticationPrincipal User user,
            @RequestBody SaveToCartRequest request
    ) throws AccessDeniedException {
        CartDto cartDto = cartService.saveToCart(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Save product to cart successfully", cartDto));
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<ApiResponse<CartDto>> deleteCartItem(
            @PathVariable(name = "itemId") Integer itemId,
            @AuthenticationPrincipal User user
    ) throws AccessDeniedException {
        CartDto cartDto = cartService.deleteCartItem(itemId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Delete cart item successfully", cartDto));
    }
}
