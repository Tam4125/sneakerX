package com.example.sneakerx.entities;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "attribute_values")
public class AttributeValue {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer valueId;

    @ManyToOne
    @JoinColumn(name = "attribute_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private ProductAttribute attribute;

    private String value;
    private String imageUrl;
}
