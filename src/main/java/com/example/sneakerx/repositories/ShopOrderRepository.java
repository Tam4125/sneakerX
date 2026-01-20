package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Shop;
import com.example.sneakerx.entities.ShopOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface ShopOrderRepository extends JpaRepository<ShopOrder, Integer> {
    Optional<ShopOrder> findByShopOrderId(Integer shopOrderId);
    List<ShopOrder> findAllByShop(Shop shop);
}
