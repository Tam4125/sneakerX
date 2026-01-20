package com.example.sneakerx.services;

import com.example.sneakerx.config.AppProperties;
import com.example.sneakerx.dtos.order.ShopOrderDto;
import com.example.sneakerx.dtos.product.ProductDetailResponse;
import com.example.sneakerx.dtos.shop.*;
import com.example.sneakerx.entities.*;
import com.example.sneakerx.exceptions.ResourceNotFoundException;
import com.example.sneakerx.mappers.OrderMapper;
import com.example.sneakerx.mappers.ProductMapper;
import com.example.sneakerx.mappers.ShopMapper;
import com.example.sneakerx.repositories.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ShopService {
    //Repository
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ShopOrderRepository shopOrderRepository;

    // Utils
    private final ShopMapper shopMapper;
    private final ProductMapper productMapper;
    private final OrderMapper orderMapper;

    private final AppProperties appProperties;

    private ShopDetailResponse toShopDetailResponse(Shop shop) {
        ShopDetailResponse shopDetailResponse = new ShopDetailResponse();
        shopDetailResponse.setShop(shopMapper.toShopDto(shop));
        if(shop.getShopOrders() != null) {
            shopDetailResponse.setShopOrders(shop.getShopOrders().stream().map(orderMapper::toShopOrderDto).toList());
        }
        if(shop.getProducts() != null) {
            shopDetailResponse.setProducts(shop.getProducts().stream().map(productMapper::toProductDto).toList());
        }
         if(shop.getFollowers() != null) {
             shopDetailResponse.setFollowers(shop.getFollowers().stream().map(shopMapper::toShopFollowerDto).toList());
         }

         return shopDetailResponse;
    }

    public ShopDetailResponse getCurrentUserShop(User user) {
        Shop shop = shopRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("User does not have a shop yet"));

        return toShopDetailResponse(shop);
    }

    public ShopDetailResponse getShopById(Integer shopId) {
        Shop shop = shopRepository.findByShopId(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        return toShopDetailResponse(shop);
    }

    public List<ShopOrderDto> getShopOrders(User user) {
        Shop shop = shopRepository.findByUser(user)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        List<ShopOrder> shopOrders = shopOrderRepository.findAllByShop(shop);
        return shopOrders.stream().map(orderMapper::toShopOrderDto).toList();
    }

    public ShopDto createShop(CreateShopRequest request, User user) {
        Shop shop = new Shop();
        shop.setShopName(request.getShopName());
        shop.setShopDescription(request.getShopDescription());
        shop.setUser(user);
        shop.setRating(0F);
        shop.setFollowersCount(0);

        String logoUrl;
        if(request.getShopLogo() != null && !request.getShopLogo().isEmpty()) {
            logoUrl = request.getShopLogo();
        } else {
            logoUrl = appProperties.getDefaultAvtUrl();
        }
        shop.setShopLogo(logoUrl);

        Shop savedShop = shopRepository.save(shop);
        return shopMapper.toShopDto(savedShop);
    }

    public ShopDto updateShop(UpdateShopRequest request) {
        Shop shop = shopRepository.findByShopId(request.getShopId())
                        .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        shop.setShopName(request.getShopName());
        shop.setShopDescription(request.getShopDescription());

        // 2. CHECK: Is the logo null or empty?
        if (request.getShopLogo() != null && !request.getShopLogo().isEmpty()) {
            shop.setShopLogo(request.getShopLogo());
        }

        Shop savedShop = shopRepository.save(shop);
        return shopMapper.toShopDto(savedShop);
    }

    @Transactional
    public ProductDetailResponse createProduct(CreateProductRequest request, User user) throws AccessDeniedException {
        Shop shop = shopRepository.findByShopId(request.getShopId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        if(!shop.getUser().getUserId().equals(user.getUserId())) {
            throw new AccessDeniedException("Forbidden");
        }

        Product newProduct = new Product();
        newProduct.setShop(shop);
        newProduct.setName(request.getName());
        newProduct.setDescription(request.getDescription());
        newProduct.setBasePrice(request.getBasePrice());
        newProduct.setSoldCount(0);
        newProduct.setRating(0.0);

        Category category = categoryRepository.findByCategoryId(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        newProduct.setCategory(category);

        // Images
        List<ProductImage> images = new ArrayList<>();
        if (request.getImageUrls() != null) {
            for (String url : request.getImageUrls()) {
                images.add(ProductImage.builder().product(newProduct).imageUrl(url).build());
            }
        }
        newProduct.setImages(images);

        //Attributes and Values
        Map<String, AttributeValue> valueLookup = new HashMap<>();

        List<ProductAttribute> attributes = new ArrayList<>();
        if(request.getAttributes() != null) {
            for(CreateAttributeRequest attrReq : request.getAttributes()) {
                ProductAttribute attribute = new ProductAttribute();
                attribute.setName(attrReq.getName());
                attribute.setProduct(newProduct);

                List<AttributeValue> values = new ArrayList<>();
                for(CreateAttributeValueRequest valReq : attrReq.getValues()) {
                    AttributeValue value = new AttributeValue();
                    value.setAttribute(attribute);
                    value.setValue(valReq.getValue());
                    if(valReq.getImageUrl() != null) {
                        value.setImageUrl(valReq.getImageUrl());
                    }
                    values.add(value);
                    valueLookup.put(attrReq.getName() + "-" + valReq.getValue(), value); // Store for SKU linking: Key = "Color-Red"
                }
                attribute.setValues(values);

                attributes.add(attribute);
            }
        }
        newProduct.setAttributes(attributes);

        List<ProductSku> skus = new ArrayList<>();
        if(request.getSkus() != null) {
            for(CreateSkuRequest skuReq : request.getSkus()) {
                ProductSku sku = new ProductSku();
                sku.setProduct(newProduct);
                sku.setPrice(skuReq.getPrice());
                sku.setStock(skuReq.getStock());
                sku.setSkuCode(skuReq.getSkuCode());
                sku.setSoldCount(0);

                // Link SKU to Attribute Values
                List<AttributeValue> skuValues = new ArrayList<>();
                // Iterate through the user's specs (e.g. {"Color": "Red", "Size": "40"})
                if (skuReq.getSpecifications() != null) {
                    for (Map.Entry<String, String> spec : skuReq.getSpecifications().entrySet()) {
                        // Reconstruct key: "Color-Red"
                        String key = spec.getKey() + "-" + spec.getValue();

                        // Find the EXACT object we created in Step 6
                        AttributeValue match = valueLookup.get(key);

                        if (match != null) {
                            skuValues.add(match);
                        }
                    }
                }
                sku.setValues(skuValues); // Hibernate handles the join table
                skus.add(sku);
            }
            newProduct.setSkus(skus);
        }

        Product savedProduct = productRepository.save(newProduct);
        return productMapper.toDetailResponse(savedProduct);
    }

    @Transactional
    public ProductDetailResponse updateProduct(UpdateProductRequest request, User user) throws AccessDeniedException {
        Shop shop = shopRepository.findByShopId(request.getShopId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found"));

        Product product = productRepository.findByProductId(request.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        if(!shop.getUser().getUserId().equals(user.getUserId()) || !product.getShop().getShopId().equals(request.getShopId())) {
            throw new AccessDeniedException("Forbidden");
        }

        product.setShop(shop);
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setBasePrice(request.getBasePrice());

        Category category = categoryRepository.findByCategoryId(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        product.setCategory(category);

        // Image handling
        List<ProductImage> currentImages = product.getImages();
        if(request.getKeepImages() != null) {
            currentImages.removeIf((existingImg) -> !request.getKeepImages().contains(existingImg.getImageId()));
        }

        if(request.getNewImageUrls() != null) {
            currentImages.addAll(
                    request.getNewImageUrls().stream().map(
                            (imageUrl) -> ProductImage.builder()
                                    .product(product)
                                    .imageUrl(imageUrl)
                                    .build()
                    ).toList()
            );
        }


        // Keep Attributes and Values handling
        Map<String, AttributeValue> valueLookup = new HashMap<>();

        List<ProductAttribute> attributes = product.getAttributes();
        if(request.getKeepAttributesKeepValues() != null) {
            attributes.removeIf((attribute) -> !request.getKeepAttributesKeepValues().keySet().stream().toList().contains(attribute.getAttributeId()));
        }

        for(ProductAttribute attribute : attributes) {
            List<AttributeValue> values = attribute.getValues();
            List<Integer> keepValues = request.getKeepAttributesKeepValues().get(attribute.getAttributeId());
            values.removeIf((value) -> !keepValues.contains(value.getValueId()));

            for(AttributeValue value : values) {
                valueLookup.put(attribute.getName() + "-" + value.getValue(),value);
            }

            // New Value for existing attribute
            if(request.getKeepAttributesNewValues() != null) {
                List<CreateAttributeValueRequest> newValuesRequest = request.getKeepAttributesNewValues().get(attribute.getAttributeId());
                if(newValuesRequest != null) {
                    for(CreateAttributeValueRequest newValueRequest : newValuesRequest) {
                        AttributeValue newValue = AttributeValue.builder()
                                .attribute(attribute)
                                .value(newValueRequest.getValue())
                                .build();
                        if(newValueRequest.getImageUrl() != null) {
                            newValue.setImageUrl(newValueRequest.getImageUrl());
                        }

                        values.add(newValue);
                        valueLookup.put(attribute.getName() + "-" + newValue.getValue(),newValue);
                    }
                }
            }
        }

        // New Attribute
        if(request.getNewAttributes() != null) {
            for(CreateAttributeRequest attrReq : request.getNewAttributes()) {
                ProductAttribute attribute = new ProductAttribute();
                attribute.setName(attrReq.getName());
                attribute.setProduct(product);

                List<AttributeValue> values = new ArrayList<>();
                for(CreateAttributeValueRequest valReq : attrReq.getValues()) {
                    AttributeValue value = new AttributeValue();
                    value.setAttribute(attribute);
                    value.setValue(valReq.getValue());
                    if(valReq.getImageUrl() != null) {
                        value.setImageUrl(valReq.getImageUrl());
                    }
                    values.add(value);
                    valueLookup.put(attrReq.getName() + "-" + valReq.getValue(), value); // Store for SKU linking: Key = "Color-Red"
                }
                attribute.setValues(values);

                attributes.add(attribute);
            }
        }

        // Skus handling
        List<ProductSku> skus = product.getSkus();
        if(request.getExistingSkus() != null) {
            List<Integer> skuIdsToKeep = request.getExistingSkus().stream()
                    .map(UpdateSkuRequest::getSkuId).toList();
            skus.removeIf((sku) -> !skuIdsToKeep.contains(sku.getSkuId()));
            for (UpdateSkuRequest req : request.getExistingSkus()) {
                product.getSkus().stream()
                        .filter(s -> s.getSkuId().equals(req.getSkuId()))
                        .findFirst()
                        .ifPresent(existingSku -> {
                            existingSku.setPrice(req.getPrice());
                            existingSku.setStock(req.getStock());
                        });
            }
        }
        if(request.getNewSkus() != null) {
            List<ProductSku> newSkus = new ArrayList<>();
            for(CreateSkuRequest newSkuRequest : request.getNewSkus()) {
                ProductSku sku = new ProductSku();
                sku.setProduct(product);
                sku.setPrice(newSkuRequest.getPrice());
                sku.setStock(newSkuRequest.getStock());
                sku.setSkuCode(newSkuRequest.getSkuCode());
                sku.setSoldCount(0);

                // Link SKU to Attribute Values
                List<AttributeValue> skuValues = new ArrayList<>();
                if (newSkuRequest.getSpecifications() != null) {
                    for (Map.Entry<String, String> spec : newSkuRequest.getSpecifications().entrySet()) {
                        // Reconstruct key: "Color-Red"
                        String key = spec.getKey() + "-" + spec.getValue();

                        // Find the EXACT object we created in Step 6
                        AttributeValue match = valueLookup.get(key);

                        if (match != null) {
                            skuValues.add(match);
                        }
                    }
                }
                sku.setValues(skuValues);
                newSkus.add(sku);
            }
            skus.addAll(newSkus);
        }

        Product savedProduct = productRepository.save(product);
        return productMapper.toDetailResponse(savedProduct);
    }
}
