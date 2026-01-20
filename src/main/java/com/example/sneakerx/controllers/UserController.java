package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.user.*;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.services.UserService;
import com.example.sneakerx.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;
import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;


    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(
            @AuthenticationPrincipal User user
    ) {
        UserDto currentUser = userService.getCurrentUser(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get current user successfully", currentUser));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> updateUserDetail(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateUserRequest request
    ) {
        UserDto userDto = userService.updateUserDetail(request,user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update user detail successfully", userDto));
    }


    @GetMapping("/addresses")
    public ResponseEntity<ApiResponse<List<UserAddressDto>>> getUserAddresses(
            @AuthenticationPrincipal User user
    ) {
        List<UserAddressDto> userAddresses = userService.getCurrentUserAddresses(user);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get user addresses successfully", userAddresses));
    }

    @PostMapping("/addresses")
    public ResponseEntity<ApiResponse<UserAddressDto>> createUserAddress(
            @AuthenticationPrincipal User user,
            @RequestBody CreateAddressRequest request
    ) {
        UserAddressDto newUserAddress = userService.createUserAddress(request, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Create user addresses successfully", newUserAddress));

    }

    @PutMapping("/addresses/{addressId}")
    public ResponseEntity<ApiResponse<UserAddressDto>> updateUserAddress(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "addressId") Integer addressId,
            @RequestBody UpdateAddressRequest request
    ) throws AccessDeniedException {
        UserAddressDto userAddress = userService.updateUserAddress(request, addressId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update user addresses successfully", userAddress));
    }

    @DeleteMapping("/addresses/{addressId}")
    public ResponseEntity<ApiResponse<String>> deleteUserAddress(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "addressId") Integer addressId
    ) throws AccessDeniedException {
        userService.deleteUserAddress(addressId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Delete user addresses successfully", "Delete user addresses successfully"));
    }

    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(
            @AuthenticationPrincipal User user
    ) {
        List<OrderDto> orders = userService.getOrders(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get orders by user successfully", orders));

    }

}
