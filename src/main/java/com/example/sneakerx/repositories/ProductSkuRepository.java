package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.ProductSku;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProductSkuRepository extends JpaRepository<ProductSku, Integer> {
    Optional<ProductSku> findBySkuId(Integer skuId);
}
