package com.example.sneakerx.controllers;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.user.*;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.mappers.UserMapper;
import com.example.sneakerx.repositories.UserRepository;
import com.example.sneakerx.services.UserService;
import com.example.sneakerx.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.file.AccessDeniedException;
import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<CurrentUserResponse>> getCurrentUser(
            @AuthenticationPrincipal User user
    ) {
        CurrentUserResponse currentUserResponse = new CurrentUserResponse(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get current user successfully", currentUserResponse));
    }

    @GetMapping("/me/detail")
    public ResponseEntity<ApiResponse<UserDto>> getUserDetail(
            @AuthenticationPrincipal User user
    ) {
        UserDto userDto = userMapper.mapToUserDto(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get user detail successfully", userDto));
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
                .body(ApiResponse.ok("Get user addresses successfully", newUserAddress));

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
                .body(ApiResponse.ok("Get user addresses successfully", userAddress));
    }

    @DeleteMapping("/addresses/{addressId}")
    public ResponseEntity<ApiResponse<String>> deleteUserAddress(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "addressId") Integer addressId
    ) throws AccessDeniedException {
        userService.deleteUserAddress(addressId, user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get user addresses successfully", ""));
    }

    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(
            @AuthenticationPrincipal User user
    ) {
        List<OrderDto> orderDtos = userService.getAllOrders(user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Get orders by user successfully", orderDtos));

    }

    @PutMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserDto>> updateUserDetail(
            @AuthenticationPrincipal User user,
            @PathVariable(name = "userId") Integer userId,
            @ModelAttribute UpdateUserRequest request
    ) throws IOException {
        UserDto userDto = userService.updateUserDetail(request,user);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.ok("Update user detail successfully", userDto));
    }

}
