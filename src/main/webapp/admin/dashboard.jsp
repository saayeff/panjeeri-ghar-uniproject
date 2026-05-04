<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Panjeeri Ghar</title>
    <%@ include file="admin-style.jsp" %>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">
    <h2 class="page-title">Dashboard</h2>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-value">${totalOrders}</div>
            <div class="stat-label">Total Orders</div>
        </div>
        <div class="stat-card highlight">
            <div class="stat-value">&#8377;${totalRevenue}</div>
            <div class="stat-label">Revenue (Paid)</div>
        </div>
        <div class="stat-card">
            <div class="stat-value">${totalProducts}</div>
            <div class="stat-label">Active Products</div>
        </div>
        <div class="stat-card">
            <div class="stat-value">${totalUsers}</div>
            <div class="stat-label">Registered Users</div>
        </div>
        <div class="stat-card warn">
            <div class="stat-value">${pendingOrders}</div>
            <div class="stat-label">Pending Orders</div>
        </div>
    </div>

    <div class="card">
        <h3 class="card-title">Recent Orders</h3>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Order ID</th><th>Customer</th><th>Amount</th>
                    <th>Order Status</th><th>Payment</th><th>Date</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="o" items="${recentOrders}">
                    <tr>
                        <td><a href="${pageContext.request.contextPath}/admin/orders">#${o.orderId}</a></td>
                        <td>${o.customerName}</td>
                        <td>&#8377;${o.amount}</td>
                        <td><span class="badge badge-${o.orderStatus}">${o.orderStatus}</span></td>
                        <td><span class="badge badge-${o.paymentStatus}">${o.paymentStatus}</span></td>
                        <td>${o.createdAt}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
