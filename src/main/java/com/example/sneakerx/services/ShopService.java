package com.example.sneakerx.services;

import com.example.sneakerx.dtos.order.OrderDto;
import com.example.sneakerx.dtos.order.OrderItemDto;
import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.shop.*;
import com.example.sneakerx.dtos.user.UpdateUserRequest;
import com.example.sneakerx.dtos.user.UserDto;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.entities.enums.ProductStatus;
import com.example.sneakerx.entities.enums.UserStatus;
import com.example.sneakerx.entities.enums.VariantType;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.OrderMapper;
import com.example.sneakerx.mappers.ProductMapper;
import com.example.sneakerx.mappers.ShopMapper;
import com.example.sneakerx.repositories.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.hibernate.ResourceClosedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.AccessDeniedException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShopService {
    private final ShopRepository shopRepository;
    private final ShopMapper shopMapper;
    private final ProductRepository productRepository;
    private final CloudinaryService cloudinaryService;
    private final ProductImageRepository productImageRepository;
    private final ProductVariantRepository productVariantRepository;
    private final ProductMapper productMapper;
    private final OrderMapper orderMapper;
    private final UserAddressesRepository userAddressesRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CategoryRepository categoryRepository;

    public ShopDto getShopById(Integer shopId) {
        Shop shop = shopRepository.findByShopId(shopId).orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        return shopMapper.mapToShopDto(shop);
    }

    @Transactional
    public ProductDetailResponse createProduct(CreateProductRequest request, List<MultipartFile> images, User user) throws IOException {
        Shop shop = shopRepository.findByShopId(request.getShopId()).orElseThrow(() -> new ResourceNotFoundException("Shop not found"));
        if(!(Objects.equals(shop.getUser().getUserId(), user.getUserId()))) {
            throw new AccessDeniedException("Forbidden");
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));


        Product newProduct = new Product();
        newProduct.setName(request.getName());
        newProduct.setShop(shop);
        newProduct.setDescription(request.getDescription());
        newProduct.setStatus(request.getStatus() != null ? ProductStatus.valueOf(request.getStatus()) : ProductStatus.ACTIVE);
        newProduct.setCategory(category);
        newProduct.setSoldCount(0);
        newProduct.setRating(0.0);

        Product product = productRepository.save(newProduct);

        List<ProductVariant> productVariants = request.getVariants().stream().map(
                (variant) -> ProductVariant.builder()
                        .variantType(VariantType.valueOf(variant.getVariantType()))
                        .variantValue(variant.getVariantValue())
                        .price(variant.getPrice())
                        .stock(variant.getStock())
                        .product(product)
                        .build()
        ).toList();

        List<String> imageUrls = new ArrayList<>();
        if (images != null && !images.isEmpty()) {
            for (MultipartFile file : images) {
                // Upload to cloud
                String url = cloudinaryService.uploadProductMedia(file, request.getShopId());
                imageUrls.add(url);
            }
        }

        List<ProductImage> productImages = imageUrls.stream().map(
                (url) -> ProductImage.builder()
                        .imageUrl(url)
                        .product(product)
                        .build()
        ).toList();

        productVariantRepository.saveAll(productVariants);
        productImageRepository.saveAll(productImages);

        product.setImages(productImages);
        product.setVariants(productVariants);
        return productMapper.mapToDetailResponse(product);
    }

    @Transactional
    public ProductDetailResponse updateProduct(Integer productId, UpdateProductRequest request, List<MultipartFile> newImages, User user) throws IOException {

        Product product = productRepository.findByProductId(productId).orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        if (!product.getShop().getUser().getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("You do not own this product");
        }
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));


        product.setName(request.getName());
        product.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            product.setStatus(ProductStatus.valueOf(request.getStatus()));
        }
        product.setCategory(category);

        // 3. SYNC IMAGES
        // A. Delete Removed Images
        // Logic: If a DB image URL is NOT in 'keepImageUrls', the user deleted it in UI.
        List<String> keptUrls = request.getKeepImageUrls() != null ? request.getKeepImageUrls() : new ArrayList<>();

        // Use iterator to remove safely while looping
        product.getImages().removeIf(img -> !keptUrls.contains(img.getImageUrl()));

        // B. Upload & Add New Images
        if (newImages != null && !newImages.isEmpty()) {
            for (MultipartFile file : newImages) {
                String url = cloudinaryService.uploadProductMedia(file, product.getShop().getShopId());

                ProductImage newImg = ProductImage.builder()
                        .imageUrl(url)
                        .product(product) // Link to parent
                        .build();

                // Add to the Parent's list (Hibernate will insert this)
                product.getImages().add(newImg);
            }
        }

        // 4. SYNC VARIANTS
        Map<Integer, VariantUpdateRequest> updateMap = request.getVariants().stream()
                .filter(v -> v.getVariantId() != null)
                .collect(Collectors.toMap(VariantUpdateRequest::getVariantId, v -> v));

        // A. Remove Variants not in the request (User deleted them)
        product.getVariants().removeIf(v -> !updateMap.containsKey(v.getVariantId()));


        // B. Update Existing Variants
        for (ProductVariant existingVariant : product.getVariants()) {
            // Since we already removed the deleted ones, every item left here MUST be in the map
            VariantUpdateRequest dto = updateMap.get(existingVariant.getVariantId());

            if (dto != null) {
                existingVariant.setVariantType(VariantType.valueOf(dto.getVariantType()));
                existingVariant.setVariantValue(dto.getVariantValue());
                existingVariant.setPrice(dto.getPrice());
                existingVariant.setStock(dto.getStock());
            }
        }


        // C. Add New Variants (ID is null)
        List<VariantUpdateRequest> newVariantDtos = request.getVariants().stream()
                .filter(v -> v.getVariantId() == null)
                .toList();

        for (VariantUpdateRequest dto : newVariantDtos) {
            ProductVariant newVariant = ProductVariant.builder()
                    .product(product) // Link to parent
                    .variantType(VariantType.valueOf(dto.getVariantType()))
                    .variantValue(dto.getVariantValue())
                    .price(dto.getPrice())
                    .stock(dto.getStock())
                    .build();

            // Add to the Parent's list (Hibernate will insert this)
            product.getVariants().add(newVariant);
        }

        // 6. FINAL SAVE
        // Because we modified product.getImages() and product.getVariants(),
        // saving the parent will cascadingly update/delete/insert everything.
        Product savedProduct = productRepository.save(product);

        return productMapper.mapToDetailResponse(savedProduct);
    }

    public List<OrderItemDto> getAllOrderItems(Integer shopId) {
        Shop shop = shopRepository.findByShopId(shopId)
                .orElseThrow(() -> new ResourceClosedException("Shop not found"));

        List<OrderItem> orderItems = orderItemRepository.findAllByShop(shop);

        return orderItems.stream().map(
                orderMapper::mapToOrderItemDto
        ).toList();

    }

    public List<OrderDto> getAllOrders(Integer shopId) {
        Shop shop = shopRepository.findByShopId(shopId)
                .orElseThrow(() -> new ResourceClosedException("Shop not found"));

        List<OrderItem> orderItems = orderItemRepository.findAllByShop(shop);

        List<Order> orders = orderItems.stream().map(
                OrderItem::getOrder
        ).toList();

        return orders.stream().map(
                orderMapper::mapToOderDto
        ).toList();

    }


    public ShopDto createShop(CreateShopRequest request, User user) throws IOException {
        Shop shop = new Shop();
        shop.setShopName(request.getShopName());
        shop.setShopDescription(request.getShopDescription());
        shop.setUser(user);
        shop.setFollowersCount(0);
        shop.setRating(0f);

        Shop savedShop = shopRepository.save(shop);

        String logoUrl;

        // 2. CHECK: Is the logo null or empty?
        if (request.getShopLogo() != null && !request.getShopLogo().isEmpty()) {
            // Upload provided image
            logoUrl = cloudinaryService.uploadShop(request.getShopLogo(), savedShop.getShopId());
        } else {
            // ASSIGN DEFAULT VALUE
            logoUrl = "https://res.cloudinary.com/dprivf9nt/image/upload/v1766715383/Profile_avatar_placeholder_large_qrfeir.png";
        }

        savedShop.setShopLogo(logoUrl);

        Shop finalShop = shopRepository.save(savedShop);

        return shopMapper.mapToShopDto(finalShop);
    }

    public ShopDto updateShop(UpdateShopRequest request) throws IOException {
        Shop shop = shopRepository.findByShopId(request.getShopId())
                        .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        shop.setShopName(request.getShopName());
        shop.setShopDescription(request.getShopDescription());

        // 2. CHECK: Is the logo null or empty?
        if (request.getShopLogo() != null && !request.getShopLogo().isEmpty()) {
            // Upload provided image
            String avatarUrl = cloudinaryService.uploadShop(request.getShopLogo(), request.getShopId());
            shop.setShopLogo(avatarUrl);
        }

        Shop savedShop = shopRepository.save(shop);
        return shopMapper.mapToShopDto(savedShop);
    }
}
