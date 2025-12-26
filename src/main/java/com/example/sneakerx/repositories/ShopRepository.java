package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ShopRepository extends JpaRepository<Shop, Integer> {
    Optional<Shop> findByShopId(Integer shopId);

    Optional<Shop> findByUser(User user);
}
