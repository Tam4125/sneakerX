package com.example.sneakerx.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "order_items")
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer orderItemId;

    @ManyToOne
    @JoinColumn(name = "shop_order_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private ShopOrder shopOrder;

    @ManyToOne
    @JoinColumn(name = "product_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Product product;

    @ManyToOne
    @JoinColumn(name = "sku_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private ProductSku sku;

    private String productNameSnapshot;
    private String skuNameSnapshot;
    private Double priceAtPurchase;
    private Integer quantity;
}
