<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .product-layout { display: flex; gap: 56px; align-items: flex-start; }
        .product-img-col { width: 480px; flex-shrink: 0; }
        .product-img-main { border-radius: 0px; overflow: hidden; border: 1px solid var(--color-border); background: var(--color-bg); aspect-ratio: 1/1; }
        .product-img-main img { width: 100%; height: 100%; object-fit: cover; }
        .product-img-main .no-img { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: rgba(56,28,6,0.6); font-size: 14px; }

        .product-info-col { flex: 1; }
        .product-category-tag { font-size: 11px; font-weight: 600; letter-spacing: 0.1em; text-transform: uppercase; color: var(--color-gold); margin-bottom: 12px; display: block; }
        .product-detail-title { font-family: var(--font-heading); font-size: 32px; font-weight: 700; color: var(--color-brown); margin-bottom: 8px; line-height: 1.2; }
        .product-detail-weight { font-size: 13px; color: rgba(56,28,6,0.6); margin-bottom: 20px; }

        .price-block { margin-bottom: 20px; }
        .price-block .price { font-size: 28px; font-weight: 700; color: var(--color-brown); }
        .price-block .mrp { font-size: 16px; color: rgba(56,28,6,0.6); text-decoration: line-through; margin-left: 10px; }
        .price-block .saving { font-size: 12px; font-weight: 600; color: #2D6A27; background: #EBF5E8; padding: 3px 10px; border-radius: 4px; margin-left: 8px; }

        .stock-tag { font-size: 13px; font-weight: 600; margin-bottom: 24px; }
        .stock-tag.in  { color: #2D6A27; }
        .stock-tag.low { color: #E67E22; }
        .stock-tag.out { color: #C0392B; }

        .qty-row { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
        .qty-row label { font-size: 12px; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; color: var(--color-brown); }
        .qty-input { width: 72px; padding: 10px 16px; border: 1px solid var(--color-border); border-radius: 32px; font-size: 15px; text-align: center; }

        .btn-row { display: flex; gap: 12px; margin-bottom: 32px; }
        .btn-row form, .btn-row a { flex: 1; }
        .btn-row button, .btn-row a { width: 100%; justify-content: center; }

        .divider { border: none; border-top: 1px solid var(--color-border); margin: 28px 0; }

        .detail-block h4 { margin-bottom: 10px; }
        .detail-block p  { font-size: 14px; color: rgba(56,28,6,0.7); line-height: 1.8; margin-bottom: 20px; }

        .meta-list { list-style: none; }
        .meta-list li { display: flex; gap: 16px; font-size: 13px; padding: 8px 0; border-bottom: 1px solid var(--color-border); }
        .meta-list li:last-child { border-bottom: none; }
        .meta-list .meta-key { color: rgba(56,28,6,0.6); width: 120px; flex-shrink: 0; }
        .meta-list .meta-val { font-weight: 600; color: var(--color-brown); }

        .breadcrumb { font-size: 12px; color: rgba(56,28,6,0.6); margin-bottom: 32px; letter-spacing: 0.04em; }
        .breadcrumb a { color: rgba(56,28,6,0.6); }
        .breadcrumb a:hover { color: var(--color-gold); }

        .added-flash { display: none; }

        @media (max-width: 900px) { .product-layout { flex-direction: column; } .product-img-col { width: 100%; } }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="section">
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/home">Home</a> &nbsp;/&nbsp;
        <a href="${pageContext.request.contextPath}/home">${product.categoryName}</a> &nbsp;/&nbsp;
        ${product.name}
    </div>

    <div class="product-layout">
        <div class="product-img-col">
            <div class="product-img-main">
                <c:choose>
                    <c:when test="${not empty product.imageUrl}">
                        <img src="${product.imageUrl}" alt="${product.name}">
                    </c:when>
                    <c:otherwise><div class="no-img">No image available</div></c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="product-info-col">
            <span class="product-category-tag">${product.categoryName}</span>
            <h1 class="product-detail-title">${product.name}</h1>
            <div class="product-detail-weight">${product.weightGrams}g</div>

            <div class="price-block">
                <span class="price">&#8377;${product.price}</span>
                <c:if test="${product.mrp > product.price}">
                    <span class="mrp">&#8377;${product.mrp}</span>
                </c:if>
            </div>

            <div class="stock-tag ${product.stockQty == 0 ? 'out' : product.stockQty <= 5 ? 'low' : 'in'}">
                <c:choose>
                    <c:when test="${product.stockQty == 0}">Out of Stock</c:when>
                    <c:when test="${product.stockQty <= 5}">Only ${product.stockQty} left!</c:when>
                    <c:otherwise>In Stock</c:otherwise>
                </c:choose>
            </div>

            <c:if test="${product.stockQty > 0}">
                <div class="qty-row">
                    <label for="qty">Quantity</label>
                    <input type="number" id="qty" class="qty-input" value="1" min="1" max="${product.stockQty}">
                </div>
                <div class="btn-row">
                    <button type="button" class="btn-secondary" onclick="pdAddToCart()"
                            style="width:100%;justify-content:center;">Add to Cart</button>
                    <button type="button" class="btn-primary" onclick="pdBuyNow()"
                            style="width:100%;justify-content:center;">Buy Now</button>
                </div>
            </c:if>

            <hr class="divider">

            <div class="detail-block">
                <c:if test="${not empty product.description}">
                    <h4>Description</h4>
                    <p>${product.description}</p>
                </c:if>
                <c:if test="${not empty product.ingredients}">
                    <h4>Ingredients</h4>
                    <p>${product.ingredients}</p>
                </c:if>
                <ul class="meta-list">
                    <li><span class="meta-key">Weight</span><span class="meta-val">${product.weightGrams}g</span></li>
                    <li><span class="meta-key">Category</span><span class="meta-val">${product.categoryName}</span></li>
                    <c:if test="${not empty product.batchNumber}">
                        <li><span class="meta-key">Batch No.</span><span class="meta-val">${product.batchNumber}</span></li>
                    </c:if>
                    <c:if test="${not empty product.expiryDate}">
                        <li><span class="meta-key">Best Before</span><span class="meta-val">${product.expiryDate}</span></li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

<script>
    function pdAddToCart() {
        var qty = parseInt(document.getElementById('qty').value) || 1;
        cartAdd(${product.productId}, qty);
    }
    function pdBuyNow() {
        var qty = parseInt(document.getElementById('qty').value) || 1;
        cartAdd(${product.productId}, qty, false);
        window.location.href = '${pageContext.request.contextPath}/cart';
    }
</script>
<%@ include file="cart-drawer.jspf" %>
</body>
</html>
