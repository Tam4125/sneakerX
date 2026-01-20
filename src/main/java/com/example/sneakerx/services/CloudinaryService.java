package com.example.sneakerx.services;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
//This is where we handle the "Big Data" logic. We will check the file size and decide whether to use a normal upload or a chunked upload
public class CloudinaryService {

    private final Cloudinary cloudinary;

    // SCENARIO 1: USER AVATAR
    public String uploadUser(MultipartFile file, Integer userId) throws IOException {
        // Logic: specific folder structure "sneakerx_users/user_{ID}"
        // We name the file "avatar" so if they upload a new one, it overwrites the old one automatically.
        String publicId = "sneakerx_users/user_" + userId + "/avatar";
        Map params = ObjectUtils.asMap(
                "resource_type", "image", // Avatars are always images
                "public_id", publicId,
                "overwrite", true         // Explicitly replace the old avatar
        );
        // Standard upload (Avatars are usually small, no need for chunking)
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), params);
        return uploadResult.get("secure_url").toString();
    }

    // SCENARIO 2: SHOP PRODUCT (Images & Videos)
    public List<String> uploadProductMedia(List<MultipartFile> images, Integer shopId, Integer productId) throws IOException {
        // Logic: specific folder structure "sneakerx_products/shop_{ID}"
        List<String> imageUrls = new ArrayList<>();
        for(MultipartFile image: images) {
            String publicId = "sneakerx_products/shop_" + shopId + "/product_" + productId + "/" + UUID.randomUUID().toString();
            Map params = ObjectUtils.asMap(
                    "resource_type", "auto",
                    "public_id", publicId
            );
            Map uploadResult;
            // "Big Data" check (Video > 100MB)
            if(image.getSize() > 104857600) {
                uploadResult = cloudinary.uploader().uploadLarge(image.getInputStream(), params);
            } else {
                uploadResult = cloudinary.uploader().upload(image.getBytes(), params);
            }

            imageUrls.add(uploadResult.get("secure_url").toString());
        }

        return imageUrls;
    }

    // SCENARIO 3: SHOP AVATAR
    public String uploadShop(MultipartFile file, Integer shopId) throws IOException {
        // We name the file "avatar" so if they upload a new one, it overwrites the old one automatically.
        String publicId = "sneakerx_shops/shop_" + shopId + "/avatar";
        Map params = ObjectUtils.asMap(
                "resource_type", "image", // Avatars are always images
                "public_id", publicId,
                "overwrite", true         // Explicitly replace the old avatar
        );
        // Standard upload (Avatars are usually small, no need for chunking)
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), params);
        return uploadResult.get("secure_url").toString();
    }

}
