<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cart — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .cart-layout { display: flex; gap: 32px; align-items: flex-start; }
        .cart-main { flex: 1; }
        .cart-sidebar { width: 320px; flex-shrink: 0; }

        .cart-table { width: 100%; border-collapse: collapse; }
        .cart-table th { font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: rgba(56,28,6,0.6); font-weight: 500; padding: 0 0 16px; border-bottom: 1px solid var(--color-border); text-align: left; }
        .cart-table td { padding: 20px 0; border-bottom: 1px solid var(--color-border); vertical-align: middle; }

        .cart-product { display: flex; align-items: center; gap: 16px; }
        .cart-product img { width: 72px; height: 72px; object-fit: cover; border-radius: 0px; background: var(--color-bg); border: 1px solid var(--color-border); }
        .cart-product .no-img { width: 72px; height: 72px; background: var(--color-bg); border-radius: 0px; border: 1px solid var(--color-border); }
        .cart-product-name { font-family: var(--font-heading); font-size: 15px; font-weight: 600; color: var(--color-brown); }

        .qty-form { display: flex; align-items: center; gap: 8px; }
        .qty-form input[type=number] { width: 56px; padding: 8px 12px; border: 1px solid var(--color-border); border-radius: 32px; font-size: 13px; text-align: center; background: var(--color-white); }
        .qty-form button { padding: 8px 14px; background: var(--color-brown); color: var(--color-white); border: none; border-radius: 0px; font-size: 11px; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; cursor: pointer; transition: all 0.25s ease; }
        .qty-form button:hover { background: var(--color-gold); color: var(--color-brown); }

        .btn-remove { font-size: 12px; color: rgba(56,28,6,0.6); text-decoration: none; letter-spacing: 0.04em; transition: all 0.25s ease; }
        .btn-remove:hover { color: #C0392B; }

        .summary-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0px; padding: 28px; }
        .summary-card h3 { font-size: 16px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--color-border); }
        .summary-row { display: flex; justify-content: space-between; font-size: 14px; color: rgba(56,28,6,0.7); padding: 6px 0; }
        .summary-row.total { font-size: 18px; font-weight: 700; color: var(--color-brown); border-top: 1px solid var(--color-border); margin-top: 12px; padding-top: 16px; }
        .free-ship { color: #2D6A27; font-weight: 600; }
        .ship-note { font-size: 12px; color: rgba(56,28,6,0.6); margin: 12px 0 20px; text-align: center; }

        .empty-state { text-align: center; padding: 80px 20px; }
        .empty-state p { color: rgba(56,28,6,0.6); margin-bottom: 24px; }

        @media (max-width: 768px) { .cart-layout { flex-direction: column; } .cart-sidebar { width: 100%; } }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="section">
    <h2 style="margin-bottom:40px;">Your Cart</h2>

    <c:choose>
        <c:when test="${empty cartItems}">
            <div class="empty-state">
                <p>Your cart is empty.</p>
                <a href="${pageContext.request.contextPath}/home" class="btn-primary">Continue Shopping</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="cart-layout">
                <div class="cart-main">
                    <table class="cart-table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Price</th>
                                <th>Quantity</th>
                                <th>Subtotal</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${cartItems}">
                                <tr>
                                    <td>
                                        <div class="cart-product">
                                            <c:choose>
                                                <c:when test="${not empty item.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/${item.imageUrl}" alt="${item.name}">
                                                </c:when>
                                                <c:otherwise><div class="no-img"></div></c:otherwise>
                                            </c:choose>
                                            <span class="cart-product-name">${item.name}</span>
                                        </div>
                                    </td>
                                    <td style="font-size:15px;font-weight:600;color:var(--color-brown);">&#8377;${item.price}</td>
                                    <td>
                                        <form method="post" action="${pageContext.request.contextPath}/cart" class="qty-form">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="cartId" value="${item.cartId}">
                                            <input type="number" name="quantity" value="${item.quantity}" min="0" max="99">
                                            <button type="submit">Update</button>
                                        </form>
                                    </td>
                                    <td style="font-size:15px;font-weight:600;color:var(--color-brown);">&#8377;${item.subtotal}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/cart?action=remove&cartId=${item.cartId}"
                                           class="btn-remove"
                                           onclick="return confirm('Remove this item?')">Remove</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="cart-sidebar">
                    <div class="summary-card">
                        <h3>Order Summary</h3>
                        <div class="summary-row"><span>Subtotal</span><span>&#8377;${cartTotal}</span></div>
                        <div class="summary-row"><span>Shipping</span><span class="free-ship">Calculated at checkout</span></div>
                        <div class="summary-row total"><span>Total</span><span>&#8377;${cartTotal}</span></div>
                        <p class="ship-note">Free shipping on orders above &#8377;999</p>
                        <a href="${pageContext.request.contextPath}/checkout" class="btn-primary" style="justify-content:center;">Proceed to Checkout</a>
                        <a href="${pageContext.request.contextPath}/home" class="btn-secondary" style="width:100%;justify-content:center;margin-top:12px;">Continue Shopping</a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

<%@ include file="cart-drawer.jspf" %>
</body>
</html>
