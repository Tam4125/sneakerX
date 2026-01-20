package com.example.sneakerx.services;

import com.example.sneakerx.dtos.product.*;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.ProductMapper;
import com.example.sneakerx.repositories.*;
import jakarta.persistence.criteria.Predicate;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {
    // Repository
    private final ProductRepository productRepository;
    private final ProductReviewRepository productReviewRepository;
    private final ProductAttributeRepository productAttributeRepository;

    // Utils
    private final ProductMapper productMapper;

    public Page<ProductDto> search(ProductSearchRequest request, Pageable pageable) {
        Specification<Product> spec = buildSpecification(request);
        return productRepository.findAll(spec, pageable).map(productMapper::toProductDto);
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

                // 2. Add Min Price Predicate
                if (request.getMinPrice() != null) {
                    predicates.add(
                            cb.greaterThanOrEqualTo(root.get("basePrice"), request.getMinPrice())
                    );
                }

                // 3. Add Max Price Predicate
                if (request.getMaxPrice() != null) {
                    predicates.add(
                            cb.lessThanOrEqualTo(root.get("basePrice"), request.getMaxPrice())
                    );
                }

                // 4. IMPORTANT: Prevent Duplicate Products
                // Since a product has many variants, a join might return the same product multiple times.
                query.distinct(true);
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    public Page<ProductDto> getPopularProducts(int page, int size) {
        Pageable pageable = PageRequest.of(page,size, Sort.by("soldCount").descending());

        Page<Product> productPage = productRepository.findAll(pageable);
        return productPage.map(productMapper::toProductDto);
    }

    public Page<ProductDto> getFavouriteProducts(int page, int size) {
        Pageable pageable = PageRequest.of(page,size, Sort.by("rating").descending());

        Page<Product> productPage = productRepository.findAll(pageable);
        return productPage.map(productMapper::toProductDto);
    }

    public Page<ProductAttributeDto> getPopularAttribute(int page, int size) {
        Pageable pageable = PageRequest.of(page,size);

        Page<ProductAttribute> productAttributePage = productAttributeRepository.findPopularAttributes(pageable);
        return productAttributePage.map(productMapper::toAttributeDto);
    }

    public ProductDetailResponse getProductDetail(Integer productId) {
        Product product = productRepository.findByProductId(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product id {" + productId + "} not found"));

        return productMapper.toDetailResponse(product);
    }
    @Transactional
    public List<ProductReviewDto> createReviews(CreateReviewRequest request, User user) {
        if(!request.getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        List<Product> products = productRepository.findAllById(request.getProductIds());

        List<ProductReview> reviews = new ArrayList<>();
        for(Product product : products) {
            Double rating = request.getRatingMap().get(product.getProductId());

            List<ProductReview> currentReviews = product.getReviews();
            product.setRating((product.getRating() * currentReviews.size() + rating)/(currentReviews.size() + 1));
            productRepository.save(product);

            ProductReview review = new ProductReview();
            review.setProduct(product);
            review.setUser(user);
            review.setRating(request.getRatingMap().get(product.getProductId()));
            review.setComment(request.getCommentMap().get(product.getProductId()));

            reviews.add(review);
        }

        List<ProductReview> savedReviews = productReviewRepository.saveAll(reviews);
        return savedReviews.stream().map(productMapper::toProductReviewDto).toList();
    }

}
