package com.example.sneakerx.services;

import com.example.sneakerx.dtos.order.*;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.entities.enums.OrderStatus;
import com.example.sneakerx.entities.enums.PaymentMethod;
import com.example.sneakerx.entities.enums.PaymentStatus;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.OrderMapper;
import com.example.sneakerx.mappers.UserAddressMapper;
import com.example.sneakerx.repositories.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class OrderService {
    // Repository
    private final OrderRepository orderRepository;
    private final OrderMapper orderMapper;
    private final UserAddressesRepository userAddressesRepository;
    private final CartItemRepository cartItemRepository;
    private final ShopRepository shopRepository;
    private final ProductSkuRepository productSkuRepository;
    private final ShopOrderRepository shopOrderRepository;
    private final PaymentRepository paymentRepository;

    //Utils
    private final UserAddressMapper userAddressMapper;

    private OrderItem mapCartItemToOrderItem(CartItem cartItem) {
        ProductSku sku = cartItem.getProductSku();
        return OrderItem.builder()
                .product(sku.getProduct())
                .sku(sku)
                .priceAtPurchase(sku.getPrice())
                .productNameSnapshot(sku.getProduct().getName())
                .skuNameSnapshot(sku.getSkuCode())
                .quantity(cartItem.getQuantity())
                .build();
    }

//    public OrderDto getOrderDetail(Integer orderId) {
//        Order order = orderRepository.findByOrderId(orderId)
//                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
//
//        return orderMapper.mapToOderDto(order);
//    }

    @Transactional
    public CreateOrderResponse createOrder(CreateOrderRequest request, User user) throws BadRequestException {
        UserAddress userAddress = userAddressesRepository.findByAddressId(request.getAddressId())
                .orElseThrow(() -> new ResourceNotFoundException("User address not found"));

        // Basic attribute
        Order newOrder = new Order();
        newOrder.setUser(user);
        newOrder.setTotalAmount(request.getTotalAmount());
        newOrder.setShippingAddress(userAddressMapper.toAddressSnapshot(userAddress));

        PaymentStatus status = PaymentStatus.AWAITING_PAYMENT;
        try {
            if(request.getPaymentStatus() != null) {
                status = PaymentStatus.valueOf(request.getPaymentStatus());
            }
        } catch (IllegalArgumentException e) {
            // Log warning or stick to default
        }
        newOrder.setPaymentStatus(status);


        // Payment
        List<Payment> payments = new ArrayList<>();
        if(request.getPaymentMethod() != null) {
            Payment payment = new Payment();
            try {
                payment.setPaymentMethod(PaymentMethod.valueOf(request.getPaymentMethod()));
            } catch (IllegalArgumentException e) {
                throw new BadRequestException("Invalid Payment Method");
            }
            payment.setOrder(newOrder); // Link Payment -> Order
            payment.setAmount(request.getTotalAmount());
            payment.setTransactionId(request.getTransactionId());
            payment.setUser(user);
            payment.setPaymentStatus(status);

            if(PaymentStatus.valueOf(request.getPaymentStatus()) == PaymentStatus.PAID) {
                payment.setPaidAt(LocalDateTime.now());
            }
            payments.add(payment);
        }

        newOrder.setPayments(payments);


        List<CartItem> itemsToDelete = new ArrayList<>();
        if(request.getItemMap() != null) {
            // Shop Orders and Order Items
            List<ShopOrder> shopOrders = new ArrayList<>();
            for(Map.Entry<Integer, List<Integer>> entry : request.getItemMap().entrySet()) {
                Integer shopId = entry.getKey();
                List<Integer> itemIds = entry.getValue();
                List<CartItem> cartItems = cartItemRepository.findAllById(itemIds);
                if(cartItems.isEmpty()) continue; // Skip if bad IDs

                Shop shop = shopRepository.findByShopId(shopId)
                        .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

                ShopOrder shopOrder = ShopOrder.builder()
                        .shop(shop)
                        .order(newOrder)
                        .shippingFee(request.getShippingFeeMap().get(shopId))
                        .orderStatus(OrderStatus.PENDING)
                        .noteToSeller(request.getNoteMap().get(shopId))
                        .subTotal(request.getSubTotalMap().get(shopId))
                        .build();

                List<OrderItem> orderItems = new ArrayList<>();
                for (CartItem cartItem : cartItems) {
                    // A. Map Data
                    OrderItem orderItem = mapCartItemToOrderItem(cartItem);

                    // B. CRITICAL: Link OrderItem -> ShopOrder (Owning Side)
                    orderItem.setShopOrder(shopOrder);
                    orderItems.add(orderItem);

                    // C. Stock Deduction (Basic implementation)
                    ProductSku sku = cartItem.getProductSku();
                    if(sku.getStock() < cartItem.getQuantity()) {
                        throw new BadRequestException("Not enough stock for: " + sku.getSkuCode());
                    }
                    sku.setStock(sku.getStock() - cartItem.getQuantity());
                    productSkuRepository.save(sku); // If Transactional, explicit save might not be needed if Entity is managed, but safer to have if detached.
                }
                shopOrder.setOrderItems(orderItems);
                shopOrders.add(shopOrder);

                // Collect for deletion
                itemsToDelete.addAll(cartItems);
            }

            newOrder.setShopOrders(shopOrders);
        }

        Order savedOrder = orderRepository.save(newOrder);

        // 5. Cleanup Cart (CRITICAL STEP MISSING IN ORIGINAL)
        if (!itemsToDelete.isEmpty()) {
            cartItemRepository.deleteAll(itemsToDelete);
        }

        return CreateOrderResponse.builder()
                .orderId(savedOrder.getOrderId())
                .paymentId(savedOrder.getPayments().get(0).getPaymentId())
                .build();
    }

//    public OrderDto updateOrder(UpdateOrderRequest request, Integer orderId) throws AccessDeniedException {
//        if(!Objects.equals(orderId, request.getOrderId())) {
//            throw new AccessDeniedException("Forbidden");
//        }
//        Order order = orderRepository.findByOrderId(orderId)
//                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
//
//        if(request.getPaymentStatus() != null) {
//            order.setPaymentStatus(PaymentStatus.valueOf(request.getPaymentStatus()));
//        }
//
//        Order savedOrder = orderRepository.save(order);
//        return orderMapper.toOrderDto(savedOrder);
//    }


    public void deleteShopOrder(Integer shopOrderId, User user) throws AccessDeniedException {
        ShopOrder shopOrder = shopOrderRepository.findByShopOrderId(shopOrderId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop order not found"));

        Order order = shopOrder.getOrder();

        if(!user.getUserId().equals(order.getUser().getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        shopOrder.setOrderStatus(OrderStatus.CANCELLED);
        order.setPaymentStatus(PaymentStatus.CANCELLED);

        shopOrderRepository.save(shopOrder);
        orderRepository.save(order);
    }

    public ShopOrderDto updateShopOrder(UpdateShopOrderRequest request, Integer shopOrderId) throws AccessDeniedException {
        if(!Objects.equals(shopOrderId, request.getShopOrderId())) {
            throw new AccessDeniedException("Forbidden");
        }

        ShopOrder shopOrder = shopOrderRepository.findByShopOrderId(shopOrderId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop Order not found"));

        shopOrder.setOrderStatus(OrderStatus.valueOf(request.getOrderStatus()));

        ShopOrder savedShopOrder = shopOrderRepository.save(shopOrder);
        return orderMapper.toShopOrderDto(savedShopOrder);
    }

}
