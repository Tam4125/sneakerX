package com.example.sneakerx.services;

import com.example.sneakerx.dtos.product.*;
import com.example.sneakerx.entities.Product;
import com.example.sneakerx.entities.ProductVariant;
import com.example.sneakerx.entities.enums.ProductStatus;
import com.example.sneakerx.mappers.ProductMapper;
import com.example.sneakerx.repositories.ProductRepository;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepository;
    private final ProductMapper productMapper;

    public Page<ProductDetailResponse> search(ProductSearchRequest request, Pageable pageable) {
        Specification<Product> spec = buildSpecification(request);
        return productRepository.findAll(spec, pageable).map(productMapper::mapToDetailResponse);
    }

    private Specification<Product> buildSpecification(ProductSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Keyword search (name + description)
            if(request.getQ() != null && !request.getQ().isBlank()) {
                String keyword = "%" + request.getQ().toLowerCase() + "%";
                predicates.add(
                        cb.or(
                                cb.like(cb.lower(root.get("name")), keyword),
                                cb.like(cb.lower(root.get("description")), keyword)
                        )
                );
            }

            // Category filter
            if(request.getCategoryId() != null) {
                predicates.add(cb.equal(root.get("category").get("categoryId"), request.getCategoryId()));
            }
            // Price range
            if (request.getMinPrice() != null || request.getMaxPrice() != null) {

                // 1. JOIN the 'variants' list
                // "ProductVariant" should be the class name of the items in your list
                Join<Product, ProductVariant> variantsJoin = root.join("variants");

                // 2. Add Min Price Predicate
                if (request.getMinPrice() != null) {
                    predicates.add(
                            cb.greaterThanOrEqualTo(variantsJoin.get("price"), request.getMinPrice())
                    );
                }

                // 3. Add Max Price Predicate
                if (request.getMaxPrice() != null) {
                    predicates.add(
                            cb.lessThanOrEqualTo(variantsJoin.get("price"), request.getMaxPrice())
                    );
                }

                // 4. IMPORTANT: Prevent Duplicate Products
                // Since a product has many variants, a join might return the same product multiple times.
                query.distinct(true);
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    public ProductDetailResponse getProductDetail(Integer productId) throws Exception{
        Product product = productRepository.findByProductId(productId)
                .orElseThrow(() -> new Exception("Product not found with id: " + productId));

        if(product.getStatus() != ProductStatus.ACTIVE) {
            throw new Exception("Product is unavailable");
        }

        return productMapper.mapToDetailResponse(product);
    }

    public Page<ProductDetailResponse> getPopularProducts(Pageable pageable) {
        Page<Product> products = productRepository.findByStatusOrderBySoldCountDesc(ProductStatus.ACTIVE, pageable);
        return products.map(productMapper::mapToDetailResponse);
    }

    public Page<ProductDetailResponse> getFavouriteProducts(Pageable pageable) {
        Page<Product> products = productRepository.findByStatusOrderByRatingDesc(ProductStatus.ACTIVE, pageable);
        return products.map(productMapper::mapToDetailResponse);
    }

}
