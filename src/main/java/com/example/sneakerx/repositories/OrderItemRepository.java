package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.OrderItem;
import com.example.sneakerx.entities.Shop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findAllByShop(Shop shop);
}
