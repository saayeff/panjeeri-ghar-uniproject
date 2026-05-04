<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders — Admin</title>
    <%@ include file="admin-style.jsp" %>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">
    <h2 class="page-title">Orders</h2>

    <c:if test="${param.updated == 'true'}">
        <div class="alert-success">Order status updated.</div>
    </c:if>

    <!-- Search bar -->
    <form method="get" action="orders" style="display:flex;gap:0.5rem;margin-bottom:1rem;">
        <input type="hidden" name="status" value="${selectedStatus}">
        <input type="text" name="q" value="${param.q}" placeholder="Search by name, email or order ID..."
               style="flex:1;padding:0.5rem 0.75rem;border:1px solid #d0b89a;border-radius:6px;font-size:0.9rem;background:#fffaf5;">
        <button type="submit" class="btn-primary" style="padding:0.5rem 1rem;">Search</button>
        <c:if test="${not empty param.q}">
            <a href="orders${not empty selectedStatus ? '?status='.concat(selectedStatus) : ''}" class="btn-secondary" style="padding:0.5rem 1rem;">Clear</a>
        </c:if>
    </form>

    <!-- Filter bar -->
    <div class="filter-bar">
        <a href="orders" class="${empty selectedStatus ? 'active' : ''}">All</a>
        <a href="orders?status=pending"    class="${selectedStatus == 'pending'    ? 'active' : ''}">Pending</a>
        <a href="orders?status=confirmed"  class="${selectedStatus == 'confirmed'  ? 'active' : ''}">Confirmed</a>
        <a href="orders?status=processing" class="${selectedStatus == 'processing' ? 'active' : ''}">Processing</a>
        <a href="orders?status=shipped"    class="${selectedStatus == 'shipped'    ? 'active' : ''}">Shipped</a>
        <a href="orders?status=delivered"  class="${selectedStatus == 'delivered'  ? 'active' : ''}">Delivered</a>
        <a href="orders?status=cancelled"  class="${selectedStatus == 'cancelled'  ? 'active' : ''}">Cancelled</a>
    </div>

    <div class="card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th><th>Customer</th><th>Location</th><th>Amount</th>
                    <th>Payment</th><th>Status</th><th>Date</th><th>Update</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="o" items="${orders}">
                    <tr>
                        <td><a href="${pageContext.request.contextPath}/admin/order-detail?id=${o.orderId}" style="color:#7b3f00;font-weight:600;">#${o.orderId}</a></td>
                        <td>
                            <div>${o.customerName}</div>
                            <div style="font-size:0.8rem;color:#888;">${o.email}</div>
                        </td>
                        <td>${o.city}, ${o.state}</td>
                        <td>&#8377;${o.amount}</td>
                        <td><span class="badge badge-${o.paymentStatus}">${o.paymentStatus}</span></td>
                        <td><span class="badge badge-${o.orderStatus}">${o.orderStatus}</span></td>
                        <td style="font-size:0.82rem;">${o.createdAt}</td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/admin/orders" style="display:flex;gap:0.3rem;">
                                <input type="hidden" name="orderId" value="${o.orderId}">
                                <select name="orderStatus" class="select-sm">
                                    <option value="pending"    ${o.orderStatus=='pending'    ? 'selected':''}>Pending</option>
                                    <option value="confirmed"  ${o.orderStatus=='confirmed'  ? 'selected':''}>Confirmed</option>
                                    <option value="processing" ${o.orderStatus=='processing' ? 'selected':''}>Processing</option>
                                    <option value="shipped"    ${o.orderStatus=='shipped'    ? 'selected':''}>Shipped</option>
                                    <option value="delivered"  ${o.orderStatus=='delivered'  ? 'selected':''}>Delivered</option>
                                    <option value="cancelled"  ${o.orderStatus=='cancelled'  ? 'selected':''}>Cancelled</option>
                                </select>
                                <button type="submit" class="btn-sm">Save</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr><td colspan="8" style="text-align:center;color:#999;padding:2rem;">No orders found.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
