package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.CreateOrderRequest;
import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.UpdateOrderRequest;
import com.example.sneakerx.dtos.order.UpdateOrderStatusRequest;
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

    @GetMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderDto>> getOrderDetail(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "orderId") Integer orderId
    ) {
        OrderDto orderDto = orderService.getOrderDetail(orderId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get order detail successfully", orderDto));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<OrderDto>> createOrder(
            @AuthenticationPrincipal User user,
            @RequestBody CreateOrderRequest request
    ) throws BadRequestException {
        OrderDto orderDto = orderService.createOrder(request, user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create order successfully", orderDto));
    }

    @PutMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderDto>> updateOrder(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "orderId") Integer orderId,
            @RequestBody UpdateOrderRequest request
    ) {
        OrderDto orderDto = orderService.updateOrder(request, orderId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update order successfully", orderDto));
    }

    @PutMapping("/{orderId}/status")
    public ResponseEntity<ApiResponse<OrderDto>> updateOrderStatus(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "orderId") Integer orderId,
            @RequestBody UpdateOrderStatusRequest request
    ) {
        OrderDto orderDto = orderService.updateOrderStatus(request, orderId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update order status successfully", orderDto));
    }

    @DeleteMapping("/{orderId}")
    public ResponseEntity<ApiResponse<String>> deleteOrder(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "orderId") Integer orderId
    ) throws AccessDeniedException {
        orderService.deleteOrder(orderId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update order status successfully", "Delete Order: " + orderId));
    }

}
