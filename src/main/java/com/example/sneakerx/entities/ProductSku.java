package com.example.sneakerx.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "product_skus")
public class ProductSku {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer skuId;

    @ManyToOne
    @JoinColumn(name = "product_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Product product;

    private String skuCode;
    private Double price;
    private Integer stock;
    private Integer soldCount;

    @ManyToMany(fetch = FetchType.EAGER) // Eager because we need specs to calculate price
    @JoinTable(
            name = "sku_values_map", // <--- The Bridge Table Name
            joinColumns = @JoinColumn(name = "sku_id"),
            inverseJoinColumns = @JoinColumn(name = "value_id")
    )
    private List<AttributeValue> values;
}
