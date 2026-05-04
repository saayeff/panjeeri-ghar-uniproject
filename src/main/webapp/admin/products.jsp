<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products — Admin</title>
    <%@ include file="admin-style.jsp" %>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
        <h2 class="page-title" style="margin:0;">Products</h2>
        <a href="${pageContext.request.contextPath}/admin/products?action=add" class="btn-primary">+ Add Product</a>
    </div>

    <c:if test="${param.saved == 'true'}">
        <div class="alert-success">Product saved successfully.</div>
    </c:if>
    <c:if test="${param.deleted == 'true'}">
        <div class="alert-success">Product deactivated.</div>
    </c:if>

    <div class="card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th><th>Name</th><th>Category</th><th>Weight</th>
                    <th>Price</th><th>MRP</th><th>Stock</th><th>Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${products}">
                    <tr>
                        <td>${p.productId}</td>
                        <td>${p.name}</td>
                        <td>${p.categoryName}</td>
                        <td>${p.weightGrams}g</td>
                        <td>&#8377;${p.price}</td>
                        <td>&#8377;${p.mrp}</td>
                        <td>
                            <span style="color:${p.stockQty <= 5 ? '#c0392b' : '#256029'};font-weight:600;">
                                ${p.stockQty}
                            </span>
                        </td>
                        <td>
                            <span class="badge ${p.isActive ? 'badge-confirmed' : 'badge-cancelled'}">
                                ${p.isActive ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.productId}" class="btn-sm">Edit</a>
                            <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.productId}"
                               class="btn-sm btn-danger"
                               onclick="return confirm('Deactivate this product?')">Delete</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
