package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Category;
import com.example.sneakerx.entities.ProductAttribute;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, Integer> {
    @Query("SELECT a FROM ProductAttribute a LEFT JOIN Product p ON a.product = p GROUP BY a ORDER BY COUNT(p) DESC")
    Page<ProductAttribute> findPopularAttributes(Pageable pageable);
}
