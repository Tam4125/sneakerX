package com.example.sneakerx.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Value("${app.base-url}")
    private String baseUrl;

    private final JavaMailSender mailSender;
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendVerificationEmail(String to, String token) {

        String verifyUrl = baseUrl + "/auth/verify?token=" + token;

        String body = """
                Welcome to SneakerX 👟
                
                Please verify your account by clicking the link below.
                This link is valid for 30 minutes.
                """ + verifyUrl;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("VERIFY YOUR SNEAKERX ACCOUNT");
        message.setText(body);

        mailSender.send(message);
    }
}
