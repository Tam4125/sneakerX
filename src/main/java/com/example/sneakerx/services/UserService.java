package com.example.sneakerx.services;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.user.*;
import com.example.sneakerx.entities.Order;
import com.example.sneakerx.entities.User;
import com.example.sneakerx.entities.UserAddress;
import com.example.sneakerx.entities.enums.UserStatus;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.OrderMapper;
import com.example.sneakerx.mappers.UserAddressMapper;
import com.example.sneakerx.mappers.UserMapper;
import com.example.sneakerx.repositories.OrderRepository;
import com.example.sneakerx.repositories.RefreshTokenRepository;
import com.example.sneakerx.repositories.UserAddressesRepository;
import com.example.sneakerx.repositories.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.AccessDeniedException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserAddressesRepository userAddressesRepository;
    private final UserAddressMapper userAddressMapper;
    private final OrderMapper orderMapper;
    private final OrderRepository orderRepository;
    private final CloudinaryService cloudinaryService;
    private final UserMapper userMapper;


    public List<UserAddressDto> getCurrentUserAddresses (User user) {
        List<UserAddress> userAddresses = userAddressesRepository.findAllByUser(user);

        return userAddresses.stream().map(
                userAddressMapper::mapToUserAddressDto
        ).toList();
    }

    public UserAddressDto createUserAddress(CreateAddressRequest request, User user) {
        UserAddress userAddress = new UserAddress();

        userAddress.setRecipientName(request.getRecipientName());
        userAddress.setPhone(request.getPhone());
        userAddress.setProvinceOrCity(request.getProvinceOrCity());
        userAddress.setDistrict(request.getDistrict());
        userAddress.setWard(request.getWard());
        userAddress.setAddressLine(request.getAddressLine());
        userAddress.setUser(user);

        userAddressesRepository.save(userAddress);

        return userAddressMapper.mapToUserAddressDto(userAddress);
    }

    public UserAddressDto updateUserAddress(UpdateAddressRequest request, Integer addressId, User user) throws AccessDeniedException {
        UserAddress userAddress = userAddressesRepository.findByAddressId(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        if(!userAddress.getUser().getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        userAddress.setRecipientName(request.getRecipientName());
        userAddress.setPhone(request.getPhone());
        userAddress.setProvinceOrCity(request.getProvinceOrCity());
        userAddress.setDistrict(request.getDistrict());
        userAddress.setWard(request.getWard());
        userAddress.setAddressLine(request.getAddressLine());

        userAddressesRepository.save(userAddress);

        return userAddressMapper.mapToUserAddressDto(userAddress);
    }

    public void deleteUserAddress(Integer addressId, User user) throws AccessDeniedException {
        UserAddress userAddress = userAddressesRepository.findByAddressId(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        if(!userAddress.getUser().equals(user)) {
            throw new AccessDeniedException("Forbidden");
        }
        userAddressesRepository.delete(userAddress);

    }

    @Transactional
    public List<OrderDto> getAllOrders(User user) {
        List<Order> orders = orderRepository.findAllByUser(user);

        return orders.stream().map(
                orderMapper::mapToOderDto
        ).toList();
    }

    public UserDto updateUserDetail(UpdateUserRequest request, User user) throws IOException {
        if(!user.getUserId().equals(request.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        user.setUsername(request.getUsername());
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setStatus(UserStatus.valueOf(request.getStatus()));

        // 2. CHECK: Is the logo null or empty?
        if (request.getAvatar() != null && !request.getAvatar().isEmpty()) {
            // Upload provided image
            String avatarUrl = cloudinaryService.uploadUser(request.getAvatar(),user.getUserId());
            user.setAvatarUrl(avatarUrl);
        }

        User savedUser = userRepository.save(user);
        return userMapper.mapToUserDto(savedUser);
    }
}
