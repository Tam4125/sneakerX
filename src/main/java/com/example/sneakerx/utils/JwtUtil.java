package com.example.sneakerx.utils;

import com.example.sneakerx.entities.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {
    @Value("${JWT_SECRET}")
    private String SECRET;

    @Value("${JWT_ACCESS_TOKEN_EXPIRATION}")
    private String ACCESS_TOKEN_EXPIRATION;


    public String generateToken(User user) {
        return Jwts.builder()
                .subject(user.getUserId().toString())   // Storing ID in Subject is standard
                .claim("username", user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + Long.parseLong(ACCESS_TOKEN_EXPIRATION)))
                .signWith(SignatureAlgorithm.HS256, SECRET)
                .compact();
    }

    // 2. EXTRACT USER ID (Crucial for filtering requests)
    public String extractUserId(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // 3. EXTRACT EXPIRATION DATE
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // 4. VALIDATE TOKEN (Is it real? Is it expired?)
    public boolean validateToken(String token, UserDetails userDetails) {
        final String userId = extractUserId(token);
        // Check if token ID matches User ID and if token is not expired

        // OPTION A: If userDetails is your custom User entity
        if (userDetails instanceof com.example.sneakerx.entities.User) {
            Integer dbId = ((com.example.sneakerx.entities.User) userDetails).getUserId();
            return (userId.equals(dbId.toString()) && !isTokenExpired(token));
        }

        // Fallback if strictly standard UserDetails (unlikely in your app)
        return false;
    }

    // --- PRIVATE HELPER METHODS ---

    private <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // Converts your String secret into a Cryptographic Key object
    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET);
        return Keys.hmacShaKeyFor(keyBytes);
    }

}
