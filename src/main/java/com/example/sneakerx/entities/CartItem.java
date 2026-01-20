package com.example.sneakerx.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "cart_items")
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer itemId;

    @ManyToOne
    @JoinColumn(name = "cart_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Cart cart;

    @ManyToOne
    @JoinColumn(name = "sku_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private ProductSku productSku;

    private Integer quantity;
}
