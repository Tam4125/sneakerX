package com.example.sneakerx.entities;

import com.example.sneakerx.entities.enums.OrderStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "shop_orders")
public class ShopOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer shopOrderId;

    @ManyToOne
    @JoinColumn(name = "parent_order_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Order order;

    @ManyToOne
    @JoinColumn(name = "shop_id")
    @JsonIgnore // <--- THE FIX: Stops Jackson from serializing the Cart back to the parent
    @ToString.Exclude // <--- Stop Lombok from printing it
    @EqualsAndHashCode.Exclude
    private Shop shop;

    private Double shippingFee;
    private Double subTotal;

    @Enumerated(EnumType.STRING)
    private OrderStatus orderStatus;

    private String noteToSeller;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "shopOrder", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> orderItems;
}
