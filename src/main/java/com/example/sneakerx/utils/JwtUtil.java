package com.example.sneakerx.utils;

import com.example.sneakerx.entities.User;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtUtil {
    private final String SECRET = "9Jf8dU9kLh2o2JhV5gYkLx7TxKcQ4JxF23kPxUqPszk";
    private final long EXPIRATION = 259200000; // 3 day

    public String generateToken(User user) {
        return Jwts.builder()
                .subject(user.getUserId().toString())
                .claim("username", user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
                .signWith(SignatureAlgorithm.HS256, SECRET)
                .compact();
    }

}
