<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%@ include file="navbar.jspf" %>

<!-- Shop Header -->
<div class="shop-header">
    <p class="shop-freshness">MADE FRESH TO ORDER</p>
    <h2>All Products</h2>
    <p class="shop-freshness-desc">${fn:length(products)} product${fn:length(products) != 1 ? 's' : ''} — shipped within 2–3 days of ordering</p>
</div>

<!-- Filter & Sort Bar -->
<div class="shop-filter-bar">
    <div class="shop-filters">
        <a href="${pageContext.request.contextPath}/shop${not empty selectedSort ? '?sort='.concat(selectedSort) : ''}"
           class="filter-btn" style="${empty selectedCategory ? 'font-weight:700;' : ''}">All</a>
        <c:forEach var="cat" items="${categories}">
            <a href="${pageContext.request.contextPath}/shop?category=${cat.slug}${not empty selectedSort ? '&sort='.concat(selectedSort) : ''}"
               class="filter-btn" style="${selectedCategory == cat.slug ? 'font-weight:700;' : ''}">${cat.name}</a>
        </c:forEach>
    </div>
    <div class="shop-meta">
        <span>${fn:length(products)} items</span>
        <select onchange="location.href=this.value" style="border:1px solid var(--color-border);background:var(--color-bg);padding:6px 10px;font-size:13px;border-radius:var(--radius-inputs);color:var(--color-brown);cursor:pointer;">
            <option value="${pageContext.request.contextPath}/shop${not empty selectedCategory ? '?category='.concat(selectedCategory) : ''}" ${empty selectedSort ? 'selected' : ''}>Sort: Featured</option>
            <option value="${pageContext.request.contextPath}/shop?sort=price-asc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}"  ${selectedSort == 'price-asc'  ? 'selected' : ''}>Price: Low to High</option>
            <option value="${pageContext.request.contextPath}/shop?sort=price-desc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}" ${selectedSort == 'price-desc' ? 'selected' : ''}>Price: High to Low</option>
            <option value="${pageContext.request.contextPath}/shop?sort=name${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}"        ${selectedSort == 'name'       ? 'selected' : ''}>Name: A–Z</option>
        </select>
    </div>
</div>

<!-- Product Grid -->
<div class="products-section" style="padding-top:32px;">
    <c:choose>
        <c:when test="${empty products}">
            <div style="text-align:center;padding:80px 20px;color:rgba(56,28,6,0.5);">
                <p style="font-size:18px;margin-bottom:12px;">No products found.</p>
                <a href="${pageContext.request.contextPath}/shop" class="btn-secondary" style="width:auto;display:inline-flex;">View All</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="product-grid">
                <c:forEach var="p" items="${products}">
                    <div class="product-item">
                        <a href="${pageContext.request.contextPath}/product?id=${p.productId}" style="text-decoration:none;">
                            <div class="product-item-img" style="position:relative;">
                                <c:choose>
                                    <c:when test="${not empty p.imageUrl}">
                                        <div class="sk sk-img" style="position:absolute;inset:0;"></div>
                                        <img src="${p.imageUrl}" alt="${p.name}" loading="lazy" class="sk-fade"
                                             onload="this.classList.add('loaded');this.previousElementSibling.style.display='none';"
                                             style="width:100%;height:100%;object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="sk sk-img" style="width:100%;height:100%;"></div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </a>
                        <div style="padding:0 4px;" class="sk-fade loaded">
                            <p class="product-item-name">
                                <a href="${pageContext.request.contextPath}/product?id=${p.productId}" style="text-decoration:none;color:inherit;">${p.name}</a>
                            </p>
                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">
                                <span class="product-item-price">Rs ${p.price}</span>
                                <c:if test="${p.mrp > p.price}">
                                    <span style="font-size:12px;color:rgba(56,28,6,0.45);text-decoration:line-through;">Rs ${p.mrp}</span>
                                </c:if>
                                <span style="font-size:11px;color:rgba(56,28,6,0.5);">${p.weightGrams}g</span>
                            </div>
                            <c:choose>
                                <c:when test="${p.stockQty <= 0}">
                                    <button class="btn-primary" disabled style="opacity:0.5;cursor:not-allowed;">Sold Out</button>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn-primary" onclick="cartAdd(${p.productId}, 1, true)">Add to Cart</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
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
