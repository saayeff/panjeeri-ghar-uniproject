<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders — Panjeeri Ghar</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .order-card { background: var(--color-white); border: 1px solid var(--color-border); border-radius: 0px; margin-bottom: 16px; overflow: hidden; transition: all 0.25s ease; }
        .order-card:hover { box-shadow: 0 4px 20px rgba(56,28,6,0.08); }
        .order-header { padding: 20px 24px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; }
        .order-header:hover { background: var(--color-bg); }
        .order-meta { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; }
        .order-id { font-family: var(--font-heading); font-size: 16px; font-weight: 700; color: var(--color-brown); }
        .order-date { font-size: 13px; color: rgba(56,28,6,0.6); }
        .order-amount { font-size: 16px; font-weight: 700; color: var(--color-brown); }
        .chevron { font-size: 12px; color: rgba(56,28,6,0.6); transition: transform 0.2s; }
        .chevron.open { transform: rotate(180deg); }

        .badge { display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; }
        .badge-pending    { background: #FFF3CD; color: #856404; }
        .badge-confirmed  { background: #D1E7DD; color: #0A3622; }
        .badge-processing { background: #CFE2FF; color: #084298; }
        .badge-shipped    { background: #D0C9F5; color: #3D1A8E; }
        .badge-delivered  { background: #D1E7DD; color: #0A3622; }
        .badge-cancelled  { background: #F8D7DA; color: #842029; }
        .badge-paid       { background: #D1E7DD; color: #0A3622; }
        .badge-unpaid     { background: #FFF3CD; color: #856404; }
        .badge-failed     { background: #F8D7DA; color: #842029; }

        .order-body { display: none; padding: 0 24px 24px; border-top: 1px solid var(--color-border); }
        .order-body.open { display: block; }

        .order-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid var(--color-border); font-size: 14px; }
        .order-item:last-child { border-bottom: none; }
        .item-name { color: rgba(56,28,6,0.7); }
        .item-qty  { color: rgba(56,28,6,0.6); font-size: 12px; }

        .totals-block { margin-top: 12px; padding-top: 12px; }
        .total-row { display: flex; justify-content: space-between; font-size: 13px; color: rgba(56,28,6,0.7); padding: 4px 0; }
        .total-row.grand { font-size: 16px; font-weight: 700; color: var(--color-brown); border-top: 1px solid var(--color-border); margin-top: 8px; padding-top: 10px; }
        .free-ship { color: #2D6A27; font-weight: 600; }

        .ship-info { margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--color-border); font-size: 13px; color: rgba(56,28,6,0.7); }

        .empty-state { text-align: center; padding: 80px 20px; }
        .empty-state p { color: rgba(56,28,6,0.6); margin-bottom: 24px; }
    </style>
</head>
<body>

<%@ include file="navbar.jspf" %>

<div class="section">
    <h2 style="margin-bottom:40px;">My Orders</h2>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="empty-state">
                <p>You haven't placed any orders yet.</p>
                <a href="${pageContext.request.contextPath}/home" class="btn-primary">Start Shopping</a>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="o" items="${orders}">
                <div class="order-card">
                    <div class="order-header" onclick="toggleOrder(${o.orderId})">
                        <div class="order-meta">
                            <span class="order-id">Order #${o.orderId}</span>
                            <span class="order-date">${o.createdAt}</span>
                            <span class="badge badge-${o.orderStatus}">${o.orderStatus}</span>
                            <span class="badge badge-${o.paymentStatus}">${o.paymentStatus}</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:16px;">
                            <span class="order-amount">&#8377;${o.finalAmount}</span>
                            <span class="chevron ${expandOrderId == o.orderId ? 'open' : ''}" id="chev-${o.orderId}">&#9660;</span>
                        </div>
                    </div>
                    <div class="order-body ${expandOrderId == o.orderId ? 'open' : ''}" id="body-${o.orderId}">
                        <c:forEach var="item" items="${o.items}">
                            <div class="order-item">
                                <span class="item-name">${item.name} <span class="item-qty">x${item.quantity}</span></span>
                                <span style="font-weight:600;color:var(--color-brown);">&#8377;${item.subtotal}</span>
                            </div>
                        </c:forEach>
                        <div class="totals-block">
                            <div class="total-row"><span>Subtotal</span><span>&#8377;${o.subtotal}</span></div>
                            <div class="total-row">
                                <span>Shipping</span>
                                <c:choose>
                                    <c:when test="${o.shipping == 0}"><span class="free-ship">FREE</span></c:when>
                                    <c:otherwise><span>&#8377;${o.shipping}</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="total-row grand"><span>Total</span><span>&#8377;${o.finalAmount}</span></div>
                        </div>
                        <div class="ship-info">
                            <strong>Shipped to:</strong> ${o.address}, ${o.city}, ${o.state} — ${o.pincode}
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<footer class="footer">
    <span class="footer-copy">&copy; 2026 Panjeeri Ghar. All rights reserved.</span>
    <div class="footer-terms"><a href="#">Privacy Policy</a></div>
</footer>

<script>
    function toggleOrder(id) {
        document.getElementById('body-' + id).classList.toggle('open');
        document.getElementById('chev-' + id).classList.toggle('open');
    }
</script>
<%@ include file="cart-drawer.jspf" %>
</body>
</html>
