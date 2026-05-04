<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order #${order.orderId} — Admin</title>
    <%@ include file="admin-style.jsp" %>
    <style>
        .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 1.5rem; }
        .info-block h4 { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.05em; color: #999; margin-bottom: 0.5rem; }
        .info-block p  { font-size: 0.92rem; margin-bottom: 0.15rem; }
        .order-item-row { display: flex; align-items: center; gap: 1rem; padding: 0.8rem 0; border-bottom: 1px solid #f0e6d8; }
        .order-item-row:last-child { border-bottom: none; }
        .order-item-img { width: 52px; height: 52px; object-fit: cover; border-radius: 6px; background: #f5f0eb; flex-shrink: 0; }
        .order-item-name { font-weight: 600; font-size: 0.9rem; }
        .order-item-sub  { font-size: 0.8rem; color: #888; }
        .order-item-price { margin-left: auto; font-weight: 700; white-space: nowrap; }
        .totals-row { display: flex; justify-content: space-between; padding: 0.4rem 0; font-size: 0.9rem; }
        .totals-row.final { font-weight: 700; font-size: 1rem; border-top: 2px solid #7b3f00; margin-top: 0.5rem; padding-top: 0.8rem; }
        .back-link { display: inline-block; margin-bottom: 1rem; color: #7b3f00; text-decoration: none; font-size: 0.9rem; font-weight: 600; }
        .back-link:hover { text-decoration: underline; }
        .status-update-form { display: flex; align-items: center; gap: 0.75rem; margin-top: 0.75rem; }
    </style>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">

    <a href="${pageContext.request.contextPath}/admin/orders" class="back-link">&larr; Back to Orders</a>
    <h2 class="page-title">Order #${order.orderId}</h2>

    <div class="detail-grid">

        <!-- Customer info -->
        <div class="card">
            <p class="card-title">Customer</p>
            <div class="info-block">
                <h4>Name</h4><p>${order.customerName}</p>
                <h4 style="margin-top:0.7rem;">Email</h4><p>${order.email}</p>
                <h4 style="margin-top:0.7rem;">Phone</h4><p>${order.phone}</p>
            </div>
        </div>

        <!-- Shipping address -->
        <div class="card">
            <p class="card-title">Shipping Address</p>
            <div class="info-block">
                <p><strong>${order.shippingName}</strong></p>
                <p>${order.shippingPhone}</p>
                <p>${order.shippingAddress}</p>
                <p>${order.shippingCity}, ${order.shippingState} — ${order.shippingPincode}</p>
                <c:if test="${not empty order.notes}">
                    <h4 style="margin-top:0.7rem;">Notes</h4>
                    <p>${order.notes}</p>
                </c:if>
            </div>
        </div>

        <!-- Payment & status -->
        <div class="card">
            <p class="card-title">Payment</p>
            <div class="info-block">
                <h4>Method</h4><p>${order.paymentMethod}</p>
                <h4 style="margin-top:0.7rem;">Status</h4>
                <p><span class="badge badge-${order.paymentStatus}">${order.paymentStatus}</span></p>
            </div>
        </div>

        <!-- Order status update -->
        <div class="card">
            <p class="card-title">Order Status</p>
            <p><span class="badge badge-${order.orderStatus}">${order.orderStatus}</span></p>
            <form method="post" action="${pageContext.request.contextPath}/admin/orders" class="status-update-form">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <select name="orderStatus" class="select-sm" style="font-size:0.9rem;padding:0.4rem 0.6rem;">
                    <option value="pending"    ${order.orderStatus=='pending'    ? 'selected':''}>Pending</option>
                    <option value="confirmed"  ${order.orderStatus=='confirmed'  ? 'selected':''}>Confirmed</option>
                    <option value="processing" ${order.orderStatus=='processing' ? 'selected':''}>Processing</option>
                    <option value="shipped"    ${order.orderStatus=='shipped'    ? 'selected':''}>Shipped</option>
                    <option value="delivered"  ${order.orderStatus=='delivered'  ? 'selected':''}>Delivered</option>
                    <option value="cancelled"  ${order.orderStatus=='cancelled'  ? 'selected':''}>Cancelled</option>
                </select>
                <button type="submit" class="btn-primary" style="padding:0.4rem 1rem;">Update</button>
            </form>
            <p style="font-size:0.8rem;color:#888;margin-top:0.7rem;">Placed: ${order.createdAt}</p>
        </div>

    </div>

    <!-- Items -->
    <div class="card">
        <p class="card-title">Items Ordered</p>
        <c:forEach var="item" items="${items}">
            <div class="order-item-row">
                <img src="${pageContext.request.contextPath}/${item.imageUrl}" alt="${item.name}" class="order-item-img"
                     onerror="this.style.background='#e8ddd0';this.removeAttribute('src')">
                <div>
                    <div class="order-item-name">${item.name}</div>
                    <div class="order-item-sub">${item.weightGrams}g &bull; Qty: ${item.quantity} &bull; &#8377;${item.unitPrice} each</div>
                </div>
                <div class="order-item-price">&#8377;${item.totalPrice}</div>
            </div>
        </c:forEach>

        <div style="max-width:320px;margin-left:auto;margin-top:1rem;padding-top:1rem;border-top:1px solid #f0e6d8;">
            <div class="totals-row"><span>Subtotal</span><span>&#8377;${order.subtotal}</span></div>
            <c:if test="${order.discountAmount > 0}">
                <div class="totals-row" style="color:green;"><span>Discount</span><span>- &#8377;${order.discountAmount}</span></div>
            </c:if>
            <div class="totals-row"><span>Shipping</span><span>&#8377;${order.shippingCharge}</span></div>
            <div class="totals-row final"><span>Total</span><span>&#8377;${order.finalAmount}</span></div>
        </div>
    </div>

</div>
</body>
</html>
