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
@Table(name = "product_attributes")
public class ProductAttribute {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer attributeId;

    @ManyToOne
    @JoinColumn(name = "product_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Product product;

    private String name;

    @OneToMany(mappedBy = "attribute", orphanRemoval = true, cascade = CascadeType.ALL)
    private List<AttributeValue> values;
}
