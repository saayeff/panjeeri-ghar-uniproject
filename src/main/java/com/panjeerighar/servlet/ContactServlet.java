package com.panjeerighar.servlet;

import com.panjeerighar.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name    = request.getParameter("name")    != null ? request.getParameter("name").trim()    : "";
        String email   = request.getParameter("email")   != null ? request.getParameter("email").trim()   : "";
        String subject = request.getParameter("subject") != null ? request.getParameter("subject").trim() : "Contact Form";
        String message = request.getParameter("message") != null ? request.getParameter("message").trim() : "";

        if (name.isEmpty() || email.isEmpty() || message.isEmpty()) {
            request.setAttribute("error", "Please fill in all required fields.");
            request.getRequestDispatcher("/contact.jsp").forward(request, response);
            return;
        }

        try {
            // Forward the contact message to the store email
            String body =
                "<div style='font-family:sans-serif;max-width:600px;'>" +
                "<h3 style='color:#381C06;'>New Contact Form Submission</h3>" +
                "<p><strong>From:</strong> " + escHtml(name) + " &lt;" + escHtml(email) + "&gt;</p>" +
                "<p><strong>Subject:</strong> " + escHtml(subject) + "</p>" +
                "<p><strong>Message:</strong></p>" +
                "<p style='background:#f9f5f0;padding:16px;border-left:3px solid #DBA657;'>" + escHtml(message).replace("\n", "<br>") + "</p>" +
                "</div>";

            jakarta.mail.Session mailSession = buildMailSession();
            jakarta.mail.Message msg = new jakarta.mail.internet.MimeMessage(mailSession);
            String storeEmail = System.getenv("SMTP_USER");
            msg.setFrom(new jakarta.mail.internet.InternetAddress(storeEmail, "Panjeeri Ghar Contact", "UTF-8"));
            msg.setRecipients(jakarta.mail.Message.RecipientType.TO,
                jakarta.mail.internet.InternetAddress.parse(storeEmail));
            msg.setSubject("[Contact] " + subject);
            msg.setContent(body, "text/html;charset=UTF-8");
            jakarta.mail.Transport.send(msg);

            request.setAttribute("success", "Your message has been sent! We'll get back to you soon.");
        } catch (Exception e) {
            getServletContext().log("ContactServlet email error: " + e.getMessage(), e);
            request.setAttribute("error", "Could not send message. Please email us directly at panjeerighar@gmail.com");
        }

        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }

    private jakarta.mail.Session buildMailSession() {
        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");
        String smtpUser = System.getenv("SMTP_USER");
        String smtpPass = System.getenv("SMTP_PASS");
        return jakarta.mail.Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(smtpUser, smtpPass);
            }
        });
    }

    private String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }
}
