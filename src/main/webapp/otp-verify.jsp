<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // Guard: if no pending OTP session, bounce to login
    if (session == null || session.getAttribute("pendingOtpUserId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String maskedEmail = (String) session.getAttribute("pendingOtpEmail");
    if (maskedEmail != null && maskedEmail.contains("@")) {
        int at = maskedEmail.indexOf('@');
        String local = maskedEmail.substring(0, at);
        String domain = maskedEmail.substring(at);
        String visible = local.length() > 3 ? local.substring(0, 3) + "***" : local.substring(0, 1) + "***";
        maskedEmail = visible + domain;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Code — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .auth-wrap { min-height: calc(100vh - 68px); display: flex; align-items: center; justify-content: center; padding: 48px 20px; background: var(--color-bg); }
        .auth-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0; padding: 48px 40px; width: 100%; max-width: 440px; box-shadow: 0 4px 20px rgba(56,28,6,0.08); }
        .auth-card h2 { margin-bottom: 8px; }
        .auth-subtitle { font-size: 14px; color: rgba(56,28,6,0.6); margin-bottom: 32px; line-height: 1.6; }
        .auth-subtitle strong { color: var(--color-brown); }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 12px; font-weight: 500; letter-spacing: 0.06em; text-transform: uppercase; color: var(--color-brown); margin-bottom: 6px; }
        .otp-input { width: 100%; text-align: center; letter-spacing: 10px; font-size: 28px; font-weight: 700; color: var(--color-brown); padding: 16px 20px; border: 1px solid var(--color-border); border-radius: var(--radius-inputs); background: var(--color-white); font-family: var(--font-body); }
        .otp-input:focus { outline: none; border-color: var(--color-brown); }
        .otp-timer { font-size: 13px; color: rgba(56,28,6,0.55); text-align: center; margin-top: 12px; }
        .otp-timer span { font-weight: 600; color: var(--color-brown); }
        .resend-row { text-align: center; margin-top: 20px; font-size: 14px; color: rgba(56,28,6,0.7); }
        .resend-row button { background: none; border: none; cursor: pointer; color: var(--color-gold); font-weight: 600; font-family: var(--font-body); font-size: 14px; padding: 0; }
        .resend-row button:disabled { color: rgba(56,28,6,0.35); cursor: default; }
        .back-link { display: block; text-align: center; margin-top: 16px; font-size: 13px; color: rgba(56,28,6,0.6); text-decoration: none; }
        .back-link:hover { color: var(--color-brown); }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="auth-wrap">
    <div class="auth-card">
        <h2>Check your email</h2>
        <p class="auth-subtitle">
            We sent a 6-digit code to<br>
            <strong><%= maskedEmail %></strong><br>
            Enter it below to sign in. The code expires in 5 minutes.
        </p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="flash error">${error}</div>
        <% } %>
        <% if (request.getAttribute("info") != null) { %>
            <div class="flash success">${info}</div>
        <% } %>
        <% if (Boolean.TRUE.equals(request.getAttribute("expired"))) { %>
            <div class="resend-row" style="margin-top:0;margin-bottom:16px;">
                <a href="${pageContext.request.contextPath}/login" style="color:var(--color-gold);font-weight:600;">Return to login</a>
            </div>
        <% } else { %>

        <form method="post" action="${pageContext.request.contextPath}/otp-verify" id="otpForm">
            <div class="form-group">
                <label for="otp">Verification Code</label>
                <input type="text" id="otp" name="otp" class="otp-input"
                       maxlength="6" inputmode="numeric" pattern="[0-9]{6}"
                       autocomplete="one-time-code" placeholder="000000" required autofocus>
            </div>
            <div class="otp-timer">Code expires in <span id="countdown">5:00</span></div>
            <button type="submit" class="btn-primary" style="width:100%;justify-content:center;margin-top:20px;">Verify &amp; Sign In</button>
        </form>

        <div class="resend-row">
            Didn't receive it?
            <form method="post" action="${pageContext.request.contextPath}/otp-verify" style="display:inline;">
                <input type="hidden" name="action" value="resend">
                <button type="submit" id="resendBtn" disabled>Resend code (<span id="resendTimer">30</span>s)</button>
            </form>
        </div>

        <% } %>

        <a href="${pageContext.request.contextPath}/login" class="back-link">&#8592; Back to login</a>
    </div>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

<script>
(function() {
    // Auto-submit when 6 digits entered
    var otpInput = document.getElementById('otp');
    if (otpInput) {
        otpInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
            if (this.value.length === 6) document.getElementById('otpForm').submit();
        });
    }

    // Countdown timer (5 minutes)
    var countdownEl = document.getElementById('countdown');
    if (countdownEl) {
        var total = 5 * 60;
        var iv = setInterval(function() {
            total--;
            if (total <= 0) {
                clearInterval(iv);
                countdownEl.textContent = '0:00';
                countdownEl.style.color = 'var(--color-error)';
                return;
            }
            var m = Math.floor(total / 60);
            var s = total % 60;
            countdownEl.textContent = m + ':' + (s < 10 ? '0' : '') + s;
            if (total <= 60) countdownEl.style.color = 'var(--color-error)';
        }, 1000);
    }

    // Resend button unlock after 30s
    var resendBtn = document.getElementById('resendBtn');
    var resendTimer = document.getElementById('resendTimer');
    if (resendBtn) {
        var resendSec = 30;
        var rv = setInterval(function() {
            resendSec--;
            resendTimer.textContent = resendSec;
            if (resendSec <= 0) {
                clearInterval(rv);
                resendBtn.disabled = false;
                resendBtn.textContent = 'Resend code';
            }
        }, 1000);
    }
})();
</script>

</body>
</html>
