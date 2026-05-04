<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="contact-wrap">
    <h2 style="margin-bottom:8px;">Get in Touch</h2>
    <p class="contact-desc">Have a question, a bulk order enquiry, or just want to say hello? We'd love to hear from you.</p>

    <c:if test="${not empty error}">
        <div class="flash error">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="flash success">${success}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/contact">
        <div class="contact-row">
            <div style="display:flex;flex-direction:column;gap:6px;">
                <label style="font-size:12px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--color-brown);">Full Name *</label>
                <input type="text" name="name" value="${param.name}" placeholder="Your name" required>
            </div>
            <div style="display:flex;flex-direction:column;gap:6px;">
                <label style="font-size:12px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--color-brown);">Email Address *</label>
                <input type="email" name="email" value="${param.email}" placeholder="you@example.com" required>
            </div>
        </div>

        <div class="contact-full" style="display:flex;flex-direction:column;gap:6px;">
            <label style="font-size:12px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--color-brown);">Subject</label>
            <input type="text" name="subject" value="${param.subject}" placeholder="Order enquiry, bulk order, feedback...">
        </div>

        <div class="contact-full" style="display:flex;flex-direction:column;gap:6px;">
            <label style="font-size:12px;font-weight:500;letter-spacing:0.06em;text-transform:uppercase;color:var(--color-brown);">Message *</label>
            <textarea name="message" rows="5" placeholder="Write your message here..." required style="resize:vertical;">${param.message}</textarea>
        </div>

        <button type="submit" class="contact-submit">Send Message</button>
    </form>

    <!-- Contact info & wholesale -->
    <div class="wholesale-section">
        <h4>Wholesale & Bulk Orders</h4>
        <p>Looking to stock Panjeeri Ghar products or place a large order for events, gifting, or distribution? Get in touch and we'll work something out.</p>
        <div style="display:flex;justify-content:center;gap:32px;flex-wrap:wrap;font-size:14px;color:rgba(56,28,6,0.7);">
            <div>
                <strong style="color:var(--color-brown);display:block;margin-bottom:4px;">Email</strong>
                panjeerighar@gmail.com
            </div>
            <div>
                <strong style="color:var(--color-brown);display:block;margin-bottom:4px;">Instagram</strong>
                <a href="https://www.instagram.com/panjeerighar" target="_blank" style="color:var(--color-gold);">@panjeerighar</a>
            </div>
            <div>
                <strong style="color:var(--color-brown);display:block;margin-bottom:4px;">Location</strong>
                Hyderabad, India
            </div>
        </div>
    </div>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
    <div class="footer-social">
        <a href="https://www.instagram.com/panjeerighar" target="_blank" aria-label="Instagram">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none"/></svg>
        </a>
    </div>
</footer>

<%@ include file="cart-drawer.jspf" %>

</body>
</html>
