package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Integer> {
    Optional<Category> findByCategoryId(Integer categoryId);
    @Query("SELECT c FROM Category c LEFT JOIN Product p ON p.category = c GROUP BY c ORDER BY COUNT(p) DESC")
    Page<Category> findPopularCategories(Pageable pageable);

    List<Category> findAllByOrderByCreatedAtDesc();
}
