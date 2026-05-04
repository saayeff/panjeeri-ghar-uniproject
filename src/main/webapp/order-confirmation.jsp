<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .confirm-wrap { max-width: 680px; margin: 0 auto; }

        .success-banner { background: #EBF5E8; border: 1px solid #C3E6BF; border-radius: 0px; padding: 40px; text-align: center; margin-bottom: 32px; }
        .success-icon { font-size: 48px; margin-bottom: 16px; }
        .success-banner h2 { color: #2D6A27; margin-bottom: 8px; }
        .success-banner p { color: #555; font-size: 15px; }

        .confirm-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0px; padding: 28px; margin-bottom: 20px; }
        .confirm-card h3 { font-size: 16px; margin-bottom: 20px; padding-bottom: 14px; border-bottom: 1px solid var(--color-border); }

        .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--color-border); font-size: 14px; }
        .info-row:last-child { border-bottom: none; }
        .info-row .lbl { color: rgba(56,28,6,0.6); }
        .info-row .val { font-weight: 600; color: var(--color-brown); }

        .badge { display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; }
        .badge-pending   { background: #FFF3CD; color: #856404; }
        .badge-confirmed { background: #D1E7DD; color: #0A3622; }
        .badge-paid      { background: #D1E7DD; color: #0A3622; }
        .badge-unpaid    { background: #FFF3CD; color: #856404; }

        .order-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid var(--color-border); font-size: 14px; }
        .order-item:last-child { border-bottom: none; }

        .total-row { display: flex; justify-content: space-between; font-size: 14px; color: rgba(56,28,6,0.7); padding: 4px 0; }
        .total-row.grand { font-size: 17px; font-weight: 700; color: var(--color-brown); border-top: 1px solid var(--color-border); margin-top: 8px; padding-top: 12px; }
        .free-ship { color: #2D6A27; font-weight: 600; }

        .actions { display: flex; gap: 16px; margin-top: 8px; justify-content: center; }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="section">
    <div class="confirm-wrap">

        <div class="success-banner">
            <div class="success-icon">&#10003;</div>
            <h2>Order Placed Successfully!</h2>
            <p>Thank you for your order. We'll start processing it right away.</p>
        </div>

        <div class="confirm-card">
            <h3>Order Details</h3>
            <div class="info-row"><span class="lbl">Order ID</span><span class="val">#${orderId}</span></div>
            <div class="info-row"><span class="lbl">Date</span><span class="val">${createdAt}</span></div>
            <div class="info-row"><span class="lbl">Order Status</span><span class="val"><span class="badge badge-${orderStatus}">${orderStatus}</span></span></div>
            <div class="info-row"><span class="lbl">Payment</span><span class="val"><span class="badge badge-${paymentStatus}">${paymentStatus}</span></span></div>
        </div>

        <div class="confirm-card">
            <h3>Items Ordered</h3>
            <c:forEach var="item" items="${orderItems}">
                <div class="order-item">
                    <span>${item.name} <span style="color:rgba(56,28,6,0.6);font-size:12px;">x${item.quantity}</span></span>
                    <span style="font-weight:600;color:var(--color-brown);">&#8377;${item.subtotal}</span>
                </div>
            </c:forEach>
            <div style="margin-top:12px;">
                <div class="total-row"><span>Subtotal</span><span>&#8377;${subtotal}</span></div>
                <div class="total-row">
                    <span>Shipping</span>
                    <c:choose>
                        <c:when test="${shipping == 0}"><span class="free-ship">FREE</span></c:when>
                        <c:otherwise><span>&#8377;${shipping}</span></c:otherwise>
                    </c:choose>
                </div>
                <div class="total-row grand"><span>Total</span><span>&#8377;${finalAmount}</span></div>
            </div>
        </div>

        <div class="confirm-card">
            <h3>Shipping To</h3>
            <div class="info-row"><span class="lbl">Address</span><span class="val">${shipAddress}</span></div>
            <div class="info-row"><span class="lbl">City</span><span class="val">${shipCity}</span></div>
            <div class="info-row"><span class="lbl">State</span><span class="val">${shipState}</span></div>
            <div class="info-row"><span class="lbl">Pincode</span><span class="val">${shipPincode}</span></div>
        </div>

        <div class="actions">
            <a href="${pageContext.request.contextPath}/my-orders" class="btn-secondary">View All Orders</a>
            <a href="${pageContext.request.contextPath}/home" class="btn-primary">Continue Shopping</a>
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
