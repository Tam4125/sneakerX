package com.example.sneakerx.repositories;

import com.example.sneakerx.entities.RefreshToken;
import com.example.sneakerx.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Integer> {
    Optional<RefreshToken> findByToken(String token);

    void deleteByUser(User user);
    void deleteByToken(String token);
}
