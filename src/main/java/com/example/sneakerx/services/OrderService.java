package com.example.sneakerx.services;

import com.example.sneakerx.dtos.order.CreateOrderRequest;
import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.UpdateOrderRequest;
import com.example.sneakerx.dtos.order.UpdateOrderStatusRequest;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.entities.enums.OrderStatus;
import com.example.sneakerx.entities.enums.PaymentProvider;
import com.example.sneakerx.entities.enums.PaymentStatus;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.OrderMapper;
import com.example.sneakerx.repositories.CartItemRepository;
import com.example.sneakerx.repositories.OrderRepository;
import com.example.sneakerx.repositories.ShopRepository;
import com.example.sneakerx.repositories.UserAddressesRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderMapper orderMapper;
    private final ShopRepository shopRepository;
    private final UserAddressesRepository userAddressesRepository;
    private final CartItemRepository cartItemRepository;

    public OrderDto getOrderDetail(Integer orderId) {
        Order order = orderRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        return orderMapper.mapToOderDto(order);
    }

    @Transactional
    public OrderDto createOrder(CreateOrderRequest request, User user) throws BadRequestException {
        UserAddress userAddress = userAddressesRepository.findByAddressId(request.getAddressId())
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        List<CartItem> cartItems = cartItemRepository.findAllById(request.getCartItems());
        if (cartItems.isEmpty()) {
            throw new ResourceNotFoundException("No items selected for checkout");
        }

        Order newOrder = new Order();
        newOrder.setUser(user);
        newOrder.setOrderStatus(OrderStatus.valueOf(request.getOrderStatus()));
        newOrder.setShippingFee(request.getShippingFee());
        newOrder.setUserAddress(userAddress);


        // 4. Process Items & Calculate Total (WITH STOCK CHECK)
        List<OrderItem> orderItems = new ArrayList<>();
        double subTotal = 0;

        for (CartItem cartItem : cartItems) {
            // A. Find the correct variant
            ProductVariant variant = cartItem.getProduct().getVariants().stream()
                    .filter(v -> v.getVariantId().equals(cartItem.getSizeId())) // Assuming sizeId maps to VariantId
                    .findFirst()
                    .orElseThrow(() -> new ResourceNotFoundException("Variant not found for Product: " + cartItem.getProduct().getName()));

            // B. CHECK STOCK (Critical!)
            if (variant.getStock() < cartItem.getQuantity()) {
                throw new BadRequestException("Not enough stock for: " + cartItem.getProduct().getName());
            }

            // C. DEDUCT STOCK
            variant.setStock(variant.getStock() - cartItem.getQuantity());
            // variantRepository.save(variant); // Optional if inside @Transactional (Hibernate handles dirty checking)

            // D. Calculate Price Correctly (Price * Quantity)
            double lineItemTotal = variant.getPrice() * cartItem.getQuantity();
            subTotal += lineItemTotal;

            // E. Build OrderItem
            OrderItem orderItem = OrderItem.builder()
                    .order(newOrder)
                    .quantity(cartItem.getQuantity()) // Ensure OrderItem stores quantity too
                    .price(variant.getPrice()) // Store snapshot of price at time of purchase
                    .product(cartItem.getProduct())
                    .sizeId(cartItem.getSizeId())
                    .colorId(cartItem.getColorId())
                    .shop(cartItem.getProduct().getShop())
                    .build();

            orderItems.add(orderItem);
        }

        // 5. Finalize Totals
        double finalTotal = subTotal + request.getShippingFee();

        newOrder.setOrderItems(orderItems);
        newOrder.setTotalPrice(finalTotal);

        Payment payment = new Payment();
        payment.setUser(user);
        payment.setOrder(newOrder);
        payment.setAmount(finalTotal);
        payment.setProvider(PaymentProvider.valueOf(request.getProvider()));
        payment.setTransactionId(request.getTransactionId());
        payment.setPaymentStatus(PaymentStatus.PENDING);

        newOrder.setPayment(payment);
        Order savedOrder = orderRepository.save(newOrder);

        cartItemRepository.deleteAll(cartItems);
        return orderMapper.mapToOderDto(savedOrder);
    }

    public OrderDto updateOrder(UpdateOrderRequest request, Integer orderId) {
        UserAddress userAddress = userAddressesRepository.findByAddressId(request.getAddressId())
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        Order order = orderRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        order.setUserAddress(userAddress);
        order.setTotalPrice(request.getTotalPrice());
        order.setShippingFee(request.getShippingFee());

        Order savedOrder = orderRepository.save(order);
        return orderMapper.mapToOderDto(savedOrder);
    }

    public OrderDto updateOrderStatus(UpdateOrderStatusRequest request, Integer orderId) {
        Order order = orderRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        order.setOrderStatus(OrderStatus.valueOf(request.getOrderStatus()));

        Order savedOrder = orderRepository.save(order);
        return orderMapper.mapToOderDto(savedOrder);
    }

    public void deleteOrder(Integer orderId, User user) throws AccessDeniedException {
        Order order = orderRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        if(!user.getUserId().equals(order.getUser().getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        orderRepository.delete(order);
    }

}
