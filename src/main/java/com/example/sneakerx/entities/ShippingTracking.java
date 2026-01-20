package com.example.sneakerx.entities;

import com.example.sneakerx.entities.customClasses.CurrentLocation;
import com.example.sneakerx.entities.enums.ShippingStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "shipping_tracking")
@Builder
public class ShippingTracking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer trackingId;

    @OneToOne
    @JoinColumn(name = "shop_order_id")
    private ShopOrder shopOrder;

    @Enumerated(EnumType.STRING)
    private ShippingStatus status;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "current_location", columnDefinition = "json")
    private CurrentLocation currentLocation;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
