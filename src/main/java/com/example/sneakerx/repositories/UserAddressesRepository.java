package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.User;
import com.example.sneakerx.entities.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserAddressesRepository extends JpaRepository<UserAddress, Integer> {

    List<UserAddress> findAllByUser(User user);

    Optional<UserAddress> findByAddressId(Integer addressId);

    Optional<UserAddress> findByUserAndIsDefaultTrue(User user);
}
