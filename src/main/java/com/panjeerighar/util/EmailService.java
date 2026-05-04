package com.panjeerighar.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

public class EmailService {

    private static final String SMTP_USER = System.getenv("SMTP_USER");
    private static final String SMTP_PASS = System.getenv("SMTP_PASS");
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int    SMTP_PORT = 587;

    public static void sendOtp(String toEmail, String toName, String otp)
            throws MessagingException, UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.trust",       SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(SMTP_USER, "Panjeeri Ghar", "UTF-8"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Your Panjeeri Ghar login code: " + otp);

        String body =
            "<div style='font-family:Poppins,sans-serif;max-width:480px;margin:0 auto;background:#F9F5F0;padding:40px 32px;'>" +
            "<h2 style='color:#381C06;margin:0 0 8px;'>Panjeeri Ghar</h2>" +
            "<p style='color:rgba(56,28,6,0.7);font-size:14px;margin:0 0 32px;'>Homemade &bull; Authentic &bull; Nourishing</p>" +
            "<p style='color:#381C06;font-size:15px;margin:0 0 24px;'>Hi " + escHtml(toName) + ", here is your one-time login code:</p>" +
            "<div style='background:#fff;border:1px solid #E3D8C8;text-align:center;padding:28px;letter-spacing:12px;font-size:36px;font-weight:700;color:#381C06;'>" +
            otp +
            "</div>" +
            "<p style='color:rgba(56,28,6,0.6);font-size:13px;margin:24px 0 0;'>This code expires in <strong>5 minutes</strong>. If you did not request this, you can safely ignore this email.</p>" +
            "</div>";

        msg.setContent(body, "text/html;charset=UTF-8");
        Transport.send(msg);
    }

    private static String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
