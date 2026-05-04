<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panjeeri Ghar — Authentic Homemade Panjeeri</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%@ include file="navbar.jspf" %>

<!-- ── HERO ── -->
<section class="hero">
    <div class="hero-bg"></div>
    <div class="hero-content">
        <h1>The Original Grain Free Panjeeri</h1>
        <a href="#products" class="btn-hero">Shop all Variants</a>
    </div>
</section>

<!-- ── FEATURES ── -->
<div class="features">
    <div class="features-grid">
        <div>
            <img class="feature-icon" src="https://panjeerighar.com/cdn/shop/files/NoFillersICON.png?v=1770827079" alt="100% Natural">
            <div class="feature-title">100% Natural</div>
            <div class="feature-desc">No preservatives, no additives — just pure wholesome ingredients.</div>
        </div>
        <div>
            <img class="feature-icon" src="https://panjeerighar.com/cdn/shop/files/100_dESIgHEEicon.png?v=1770827079" alt="Pure Desi Ghee">
            <div class="feature-title">Pure Desi Ghee</div>
            <div class="feature-desc">Every batch is made fresh with traditional age-old recipes.</div>
        </div>
        <div>
            <img class="feature-icon" src="https://panjeerighar.com/cdn/shop/files/FreshICON.png?v=1770827079" alt="Free Shipping">
            <div class="feature-title">Free Shipping</div>
            <div class="feature-desc">Complimentary delivery on all orders above &#8377;999.</div>
        </div>
    </div>
</div>

<!-- ── FLASH ── -->
<c:if test="${not empty dbError}">
    <div class="flash error">${dbError}</div>
</c:if>

<!-- ── PRODUCTS ── -->
<section class="products-section" id="products">
    <h2>Our Products</h2>

    <c:choose>
        <c:when test="${empty products}">
            <p style="text-align:center;color:rgba(56,28,6,0.5);padding:4rem 0;">No products available right now.</p>
        </c:when>
        <c:otherwise>
            <div class="product-grid">
                <c:forEach var="p" items="${products}">
                    <div class="product-item">
                        <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
                            <div class="product-item-img" style="position:relative;">
                                <c:choose>
                                    <c:when test="${not empty p.imageUrl}">
                                        <div class="sk sk-img" style="position:absolute;inset:0;"></div>
                                        <img src="${p.imageUrl}" alt="${p.name}" class="sk-fade"
                                             onload="this.classList.add('loaded');this.previousElementSibling.style.display='none';"
                                             style="width:100%;height:100%;object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="sk sk-img" style="width:100%;height:100%;"></div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </a>
                        <div class="product-item-name">
                            <a href="${pageContext.request.contextPath}/product?id=${p.productId}"
                               style="color:var(--color-brown);text-decoration:none;">${p.name}</a>
                        </div>
                        <div class="product-item-price">
                            &#8377;${p.price}
                            <c:if test="${p.mrp > p.price}">
                                <span class="mrp">&#8377;${p.mrp}</span>
                            </c:if>
                        </div>
                        <c:choose>
                            <c:when test="${p.stockQty == 0}">
                                <button class="btn-primary" disabled
                                        style="margin-top:12px;opacity:0.4;cursor:not-allowed;">Out of Stock</button>
                            </c:when>
                            <c:when test="${empty sessionScope.loggedInUser}">
                                <a href="${pageContext.request.contextPath}/login"
                                   class="btn-primary" style="margin-top:12px;display:block;text-align:center;">Add to Cart</a>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-primary" style="margin-top:12px;"
                                        onclick="cartAdd(${p.productId}, 1)">Add to Cart</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<!-- ── FOOTER ── -->
<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms">
        <a href="${pageContext.request.contextPath}/home">Privacy Policy</a>
    </div>
    <div class="footer-social">
        <a href="https://www.instagram.com/panjeerigharr" target="_blank" rel="noopener" aria-label="Instagram">
            <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1112.63 8 4 4 0 0116 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
        </a>
    </div>
</footer>

<%@ include file="cart-drawer.jspf" %>
</body>
</html>
