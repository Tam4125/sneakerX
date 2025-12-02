package com.example.sneakerx.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "shop_followers")
public class ShopFollower {

    @Id
    private Integer id;

    private String shopId;
    private String userId;
    private LocalDateTime followedAt;
}
