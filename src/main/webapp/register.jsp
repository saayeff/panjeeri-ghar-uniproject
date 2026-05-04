<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .auth-wrap { min-height: calc(100vh - 68px); display: flex; align-items: center; justify-content: center; padding: 48px 20px; background: var(--color-bg); }
        .auth-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0; padding: 48px 40px; width: 100%; max-width: 480px; box-shadow: 0 4px 20px rgba(56,28,6,0.08); }
        .auth-card h2 { margin-bottom: 8px; }
        .auth-subtitle { font-size: 14px; color: rgba(56,28,6,0.6); margin-bottom: 32px; }
        .auth-footer { text-align: center; margin-top: 24px; font-size: 14px; color: rgba(56,28,6,0.7); }
        .auth-footer a { color: var(--color-gold); font-weight: 600; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 12px; font-weight: 500; letter-spacing: 0.06em; text-transform: uppercase; color: var(--color-brown); margin-bottom: 6px; }
        .or-divider { display: flex; align-items: center; gap: 12px; margin: 24px 0; color: rgba(56,28,6,0.4); font-size: 13px; }
        .or-divider::before, .or-divider::after { content:''; flex:1; height:1px; background: var(--color-border); }
        .btn-google { display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%; padding: 12px 24px; border: 1px solid var(--color-border); border-radius: var(--radius-inputs); background: #fff; color: var(--color-brown); font-family: var(--font-body); font-size: 14px; font-weight: 500; cursor: pointer; text-decoration: none; transition: border-color 0.2s, box-shadow 0.2s; }
        .btn-google:hover { border-color: var(--color-brown); box-shadow: 0 2px 8px rgba(56,28,6,0.08); }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="auth-wrap">
    <div class="auth-card">
        <h2>Create Account</h2>
        <p class="auth-subtitle">Join Panjeeri Ghar today</p>

        <a href="${pageContext.request.contextPath}/auth/google" class="btn-google">
            <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>
            Continue with Google
        </a>

        <div class="or-divider">or sign up with email</div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="flash error">${error}</div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/register">
            <div class="form-group">
                <label for="fullName">Full Name</label>
                <input type="text" id="fullName" name="fullName" value="${fullName}" placeholder="Your full name" required>
            </div>
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" value="${email}" placeholder="you@example.com" required>
            </div>
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="tel" id="phone" name="phone" value="${phone}" placeholder="03001234567" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Minimum 6 characters" required>
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" required>
            </div>
            <button type="submit" class="btn-primary" style="width:100%;justify-content:center;margin-top:8px;">Create Account</button>
        </form>

        <div class="auth-footer">
            Already have an account? <a href="${pageContext.request.contextPath}/login">Login</a>
        </div>
    </div>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

</body>
</html>
