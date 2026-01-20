package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.*;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.OrderService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

//    @GetMapping("/{orderId}")
//    public ResponseEntity<ApiResponse<OrderDto>> getOrderDetail(
//            @AuthenticationPrincipal User user,
//            @PathVariable(name = "orderId") Integer orderId
//    ) {
//        OrderDto orderDto = orderService.getOrderDetail(orderId);
//        return ResponseEntity
//                .status(HttpStatus.OK)
//                .body(ApiResponse.ok("Get order detail successfully", orderDto));
//    }

    @PostMapping
    public ResponseEntity<ApiResponse<CreateOrderResponse>> createOrder(
            @AuthenticationPrincipal User user,
            @RequestBody CreateOrderRequest request
    ) throws BadRequestException {
        CreateOrderResponse createOrderResponse = orderService.createOrder(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create order successfully", createOrderResponse));
    }

//    @PutMapping("/{orderId}")
//    public ResponseEntity<ApiResponse<OrderDto>> updateOrder(
//            @AuthenticationPrincipal User user,
//            @PathVariable(name = "orderId") Integer orderId,
//            @RequestBody UpdateOrderRequest request
//    ) throws AccessDeniedException {
//        OrderDto orderDto = orderService.updateOrder(request, orderId);
//        return ResponseEntity
//                .status(HttpStatus.OK)
//                .body(ApiResponse.ok("Update order successfully", orderDto));
//    }

    @DeleteMapping("/shop-orders/{shopOrderId}")
    public ResponseEntity<ApiResponse<String>> deleteOrder(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "shopOrderId") Integer shopOrderId
    ) throws AccessDeniedException {
        orderService.deleteShopOrder(shopOrderId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Delete order successfully", "Delete Order: " + shopOrderId));
    }

    @PutMapping("/shop-orders/{shopOrderId}")
    public ResponseEntity<ApiResponse<ShopOrderDto>> updateShopOrder(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "shopOrderId") Integer shopOrderId,
            @RequestBody UpdateShopOrderRequest request
    ) throws AccessDeniedException {
        ShopOrderDto shopOrder = orderService.updateShopOrder(request, shopOrderId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update shop order successfully", shopOrder));
    }

}
