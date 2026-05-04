<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .checkout-layout { display: flex; gap: 40px; align-items: flex-start; }
        .checkout-form-col { flex: 1; }
        .checkout-summary-col { width: 340px; flex-shrink: 0; }

        .checkout-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0px; padding: 32px; margin-bottom: 24px; }
        .checkout-card h3 { font-size: 18px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--color-border); }

        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; }

        .summary-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--color-border); font-size: 14px; }
        .summary-item:last-of-type { border-bottom: none; }
        .summary-item-name { color: rgba(56,28,6,0.7); }
        .summary-item-qty { font-size: 12px; color: rgba(56,28,6,0.6); }
        .summary-totals { margin-top: 16px; padding-top: 16px; border-top: 2px solid var(--color-border); }
        .total-row { display: flex; justify-content: space-between; font-size: 14px; color: rgba(56,28,6,0.7); padding: 4px 0; }
        .total-row.grand { font-size: 18px; font-weight: 700; color: var(--color-brown); margin-top: 10px; padding-top: 12px; border-top: 1px solid var(--color-border); }
        .free-ship { color: #2D6A27; font-weight: 600; }
        .ship-note { font-size: 12px; color: rgba(56,28,6,0.6); margin-top: 8px; text-align: center; }

        @media (max-width: 768px) { .checkout-layout { flex-direction: column-reverse; } .checkout-summary-col { width: 100%; } }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="section">
    <h2 style="margin-bottom:40px;">Checkout</h2>

    <c:if test="${param.paymentFailed == 'true'}">
        <div class="flash error">Payment failed or was cancelled. Please try again.</div>
    </c:if>

    <div class="checkout-layout">
        <div class="checkout-form-col">
            <div class="checkout-card">
                <h3>Shipping Address</h3>
                <c:if test="${not empty error}"><div class="flash error">${error}</div></c:if>
                <form method="post" action="${pageContext.request.contextPath}/checkout">
                    <div class="form-group">
                        <label for="address">Street Address</label>
                        <input type="text" id="address" name="address" value="${prefillAddress}" placeholder="House no., street, area" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" value="${prefillCity}" placeholder="City" required>
                        </div>
                        <div class="form-group">
                            <label for="state">State</label>
                            <input type="text" id="state" name="state" value="${prefillState}" placeholder="State" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" value="${prefillPincode}" placeholder="6-digit pincode" maxlength="6" required>
                    </div>
                    <div class="form-group">
                        <label for="notes">Order Notes (optional)</label>
                        <textarea id="notes" name="notes" rows="3" placeholder="Any special instructions..."></textarea>
                    </div>
                    <button type="submit" class="btn-primary" style="justify-content:center;">Place Order &amp; Pay</button>
                </form>
            </div>
        </div>

        <div class="checkout-summary-col">
            <div class="checkout-card">
                <h3>Order Summary</h3>
                <c:forEach var="item" items="${cartItems}">
                    <div class="summary-item">
                        <div>
                            <div class="summary-item-name">${item.name}</div>
                            <div class="summary-item-qty">x${item.quantity}</div>
                        </div>
                        <div style="font-weight:600;color:var(--color-brown);">&#8377;${item.subtotal}</div>
                    </div>
                </c:forEach>
                <div class="summary-totals">
                    <div class="total-row"><span>Subtotal</span><span>&#8377;${subtotal}</span></div>
                    <div class="total-row">
                        <span>Shipping</span>
                        <c:choose>
                            <c:when test="${shippingAmount == 0}"><span class="free-ship">FREE</span></c:when>
                            <c:otherwise><span>&#8377;${shippingAmount}</span></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="total-row grand"><span>Total</span><span>&#8377;${orderTotal}</span></div>
                </div>
                <c:if test="${shippingAmount > 0}">
                    <p class="ship-note">Free shipping on orders above &#8377;999</p>
                </c:if>
            </div>
        </div>
    </div>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

<%@ include file="cart-drawer.jspf" %>
</body>
</html>
