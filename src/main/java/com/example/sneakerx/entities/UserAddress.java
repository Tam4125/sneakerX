package com.example.sneakerx.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "user_addresses")
public class UserAddress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer addressId;

    private String recipientName;
    private String phone;
    private String provinceOrCity;
    private String district;
    private String ward;
    private String addressLine;
    private Boolean isDefault;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private User user;
}
