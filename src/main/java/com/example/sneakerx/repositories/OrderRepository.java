package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Order;
import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {

    Optional<Order> findByOrderId(Integer orderId);

    List<Order> findAllByUser(User user);
}
