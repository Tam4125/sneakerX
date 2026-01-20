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
import com.example.sneakerx.repositories.ShopOrderRepository;
import com.example.sneakerx.repositories.UserAddressesRepository;
import com.example.sneakerx.repositories.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    //Repository
    private final UserRepository userRepository;
    private final UserAddressesRepository userAddressesRepository;
    private final ShopOrderRepository shopOrderRepository;
    private final OrderRepository orderRepository;


    // Utils
    private final OrderMapper orderMapper;
    private final UserAddressMapper userAddressMapper;
    private final UserMapper userMapper;

    public UserDto getCurrentUser(User user) {
        return userMapper.toUserDto(user);
    }

    public UserDto updateUserDetail(UpdateUserRequest request, User user) {
        User userToUpdate = userRepository.findByUserId(user.getUserId())
                        .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        userToUpdate.setUsername(request.getUsername());
        userToUpdate.setFullName(request.getFullName());
        userToUpdate.setEmail(request.getEmail());
        userToUpdate.setPhone(request.getPhone());
        userToUpdate.setStatus(UserStatus.valueOf(request.getStatus()));

        // 2. CHECK: Is the logo null or empty?
        if (request.getAvatarUrl() != null && !request.getAvatarUrl().isEmpty()) {
            userToUpdate.setAvatarUrl(request.getAvatarUrl());
        }
        User savedUser = userRepository.save(userToUpdate);

        return userMapper.toUserDto(savedUser);
    }

    public List<UserAddressDto> getCurrentUserAddresses (User user) {
        List<UserAddress> userAddresses = userAddressesRepository.findAllByUser(user);

        return userAddresses.stream().map(
                userAddressMapper::toUserAddressDto
        ).toList();
    }
    @Transactional
    public UserAddressDto createUserAddress(CreateAddressRequest request, User user) {
        if (Boolean.TRUE.equals(request.getIsDefault())) {
            userAddressesRepository.findByUserAndIsDefaultTrue(user)
                    .ifPresent(existingDefault -> {
                        existingDefault.setIsDefault(false);
                        userAddressesRepository.save(existingDefault);
                    });
        }


        UserAddress userAddress = new UserAddress();

        userAddress.setRecipientName(request.getRecipientName());
        userAddress.setPhone(request.getPhone());
        userAddress.setProvinceOrCity(request.getProvinceOrCity());
        userAddress.setDistrict(request.getDistrict());
        userAddress.setWard(request.getWard());
        userAddress.setAddressLine(request.getAddressLine());
        userAddress.setUser(user);
        userAddress.setIsDefault(request.getIsDefault());



        userAddressesRepository.save(userAddress);

        return userAddressMapper.toUserAddressDto(userAddress);
    }
    @Transactional
    public UserAddressDto updateUserAddress(UpdateAddressRequest request, Integer addressId, User user) throws AccessDeniedException {
        if (Boolean.TRUE.equals(request.getIsDefault())) {
            userAddressesRepository.findByUserAndIsDefaultTrue(user)
                    .ifPresent(existingDefault -> {
                        existingDefault.setIsDefault(false);
                        userAddressesRepository.save(existingDefault);
                    });
        }

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
        userAddress.setIsDefault(request.getIsDefault());

        userAddressesRepository.save(userAddress);

        return userAddressMapper.toUserAddressDto(userAddress);
    }

    public void deleteUserAddress(Integer addressId, User user) throws AccessDeniedException {
        UserAddress userAddress = userAddressesRepository.findByAddressId(addressId)
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        if(!userAddress.getUser().getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }
        userAddressesRepository.delete(userAddress);
    }

    public List<OrderDto> getOrders(User user) {
        List<Order> orders = orderRepository.findAllByUser(user);

        return orders.stream().map(
                orderMapper::toOrderDto
        ).toList();
    }
}
