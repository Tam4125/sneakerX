package com.example.sneakerx.dtos.cart;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CartItemResponse {
    // --- 1. Cart Management ---
    private Integer itemId;       // To update/delete this specific row
    private Integer skuId;        // To identify the exact variant
    private Integer quantity;     // Current quantity in cart

    // --- 2. Product Navigation & Display ---
    private Integer productId;    // To navigate back to Product Detail Screen
    private String productName;   // e.g., "Nike Air Force 1"
    private String shopName;      // e.g., "Nike Official Store" (Good for multi-vendor grouping)
    private Integer shopId;       // To group items by Shop in checkout

    // --- 3. Visuals ---
    private String productImageUrl; // The specific variant image (Red Shoe) or fallback to Main Image

    // --- 4. Variant Info (Crucial) ---
    private String skuCode;       // e.g., "NK-AF1-RED-42"
    private String variantDescription; // e.g., "Color: Red, Size: 42" (Pre-formatted string)

    // --- 5. Financials ---
    private Double unitPrice;     // The current price of the SKU
    private Double subTotal;      // unitPrice * quantity (Backend should calculate this)

    // --- 6. Stock Validation (UX) ---
    private Integer currentStock; // To show "Only 2 left!" or disable "+" button
    private boolean available;  // True if stock >= quantity
}
