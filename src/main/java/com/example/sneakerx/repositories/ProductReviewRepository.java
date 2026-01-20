package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Product;
import com.example.sneakerx.entities.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, Integer> {
    List<ProductReview> findAllByProduct(Product product);
}
