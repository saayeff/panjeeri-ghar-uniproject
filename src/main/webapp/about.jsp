<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .about-hero {
            background: url('https://panjeerighar.com/cdn/shop/files/PanjeeriGharCoverImage.png?v=1770440511') center/cover no-repeat;
            position: relative; min-height: 340px; display: flex; align-items: center;
        }
        .about-hero::before { content:''; position:absolute; inset:0; background:rgba(56,28,6,0.55); }
        .about-hero-content { position:relative; z-index:1; padding: 64px 32px; color:#fff; max-width: 640px; }
        .about-hero-content h1 { font-size: clamp(28px,4vw,44px); color:#fff; margin-bottom:16px; }
        .about-hero-content p { font-size:16px; line-height:1.8; opacity:0.9; }
        .about-section { padding: 64px 32px; max-width: 800px; margin: 0 auto; }
        .about-section h3 { font-size: 22px; color: var(--color-brown); margin-bottom: 16px; }
        .about-section p { font-size: 15px; line-height: 1.9; color: rgba(56,28,6,0.8); margin-bottom: 20px; }
        .values-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; padding: 48px 32px; background: var(--color-white); border-top: 1px solid var(--color-border); border-bottom: 1px solid var(--color-border); }
        .value-card { text-align: center; padding: 32px 20px; }
        .value-title { font-size: 15px; font-weight: 700; color: var(--color-brown); margin-bottom: 10px; }
        .value-desc { font-size: 13px; color: rgba(56,28,6,0.65); line-height: 1.7; }
        .ingredients-list { display: flex; flex-wrap: wrap; gap: 10px; margin: 20px 0; }
        .ingredient-tag { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 100px; padding: 6px 16px; font-size: 13px; color: var(--color-brown); font-weight: 500; }
        @media (max-width: 640px) { .values-grid { grid-template-columns: 1fr; } .about-section { padding: 40px 20px; } }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<!-- Hero -->
<div class="about-hero">
    <div class="about-hero-content">
        <h1>Real Panjeeri.<br>The way it was meant to be.</h1>
        <p>Real Panjeeri — the kind made by our grandmothers to build strength and immunity — had disappeared. We brought it back.</p>
    </div>
</div>

<!-- Our Story -->
<div class="about-section">
    <h3>Our Story</h3>
    <p>Panjeeri Ghar was born in Hyderabad out of a simple frustration: the traditional panjeeri we grew up eating — dense, nourishing, made with care — had been replaced by cheap, diluted versions filled with atta and sooji.</p>
    <p>We eliminated every inferior ingredient and went back to the original recipe. The result is a product so dense and nutrient-rich that a small serving goes a long way. No fillers. No shortcuts. Just real food.</p>

    <h3>What Goes Inside</h3>
    <p>Every batch is made with premium natural ingredients, bound together with pure desi ghee:</p>
    <div class="ingredients-list">
        <span class="ingredient-tag">Almonds</span>
        <span class="ingredient-tag">Cashews</span>
        <span class="ingredient-tag">Pistachios</span>
        <span class="ingredient-tag">Walnuts</span>
        <span class="ingredient-tag">Gond (Edible Gum)</span>
        <span class="ingredient-tag">Pure Desi Ghee</span>
        <span class="ingredient-tag">Dry Dates</span>
        <span class="ingredient-tag">Makhana</span>
    </div>
    <p>Made fresh to order. No preservatives. Shipped within 2–3 days of your order.</p>
</div>

<!-- Values -->
<div class="values-grid">
    <div class="value-card">
        <div class="value-title">No Fillers</div>
        <div class="value-desc">We removed atta and sooji entirely. Every gram counts — only premium nuts, seeds, and ghee.</div>
    </div>
    <div class="value-card">
        <div class="value-title">Made Fresh</div>
        <div class="value-desc">We don't stockpile. Your order is made fresh and shipped within 2–3 days. Always.</div>
    </div>
    <div class="value-card">
        <div class="value-title">For Everyone</div>
        <div class="value-desc">Postpartum recovery, fitness nutrition, or simply craving the real thing — Panjeeri Ghar is for you.</div>
    </div>
</div>

<!-- CTA -->
<div style="text-align:center;padding:64px 32px;">
    <h3 style="margin-bottom:12px;">Ready to taste the difference?</h3>
    <p style="font-size:14px;color:rgba(56,28,6,0.6);margin-bottom:28px;">Order today and experience panjeeri the way it was always meant to be.</p>
    <a href="${pageContext.request.contextPath}/shop" class="btn-primary" style="width:auto;display:inline-flex;">Shop Now</a>
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
