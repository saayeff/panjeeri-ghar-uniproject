<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users — Admin</title>
    <%@ include file="admin-style.jsp" %>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">
    <h2 class="page-title">Users</h2>

    <c:if test="${param.updated == 'true'}">
        <div class="alert-success">User updated.</div>
    </c:if>

    <form method="get" action="users" style="display:flex;gap:0.5rem;margin-bottom:1rem;">
        <input type="text" name="q" value="${param.q}" placeholder="Search by name or email..."
               style="flex:1;padding:0.5rem 0.75rem;border:1px solid #d0b89a;border-radius:6px;font-size:0.9rem;background:#fffaf5;">
        <button type="submit" class="btn-primary" style="padding:0.5rem 1rem;">Search</button>
        <c:if test="${not empty param.q}">
            <a href="users" class="btn-secondary" style="padding:0.5rem 1rem;">Clear</a>
        </c:if>
    </form>

    <div class="card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th><th>Name</th><th>Email</th><th>Phone</th>
                    <th>Role</th><th>Status</th><th>Joined</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${users}">
                    <tr>
                        <td>${u.userId}</td>
                        <td>${u.fullName}</td>
                        <td>${u.email}</td>
                        <td>${u.phone}</td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline;">
                                <input type="hidden" name="userId" value="${u.userId}">
                                <input type="hidden" name="action" value="role">
                                <select name="role" class="select-sm" onchange="this.form.submit()">
                                    <option value="customer" ${u.role == 'customer' ? 'selected' : ''}>Customer</option>
                                    <option value="admin"    ${u.role == 'admin'    ? 'selected' : ''}>Admin</option>
                                </select>
                            </form>
                        </td>
                        <td>
                            <span class="badge ${u.isActive ? 'badge-confirmed' : 'badge-cancelled'}">
                                ${u.isActive ? 'Active' : 'Blocked'}
                            </span>
                        </td>
                        <td style="font-size:0.82rem;">${u.createdAt}</td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                <input type="hidden" name="userId" value="${u.userId}">
                                <input type="hidden" name="action" value="toggle">
                                <button type="submit" class="btn-sm ${u.isActive ? 'btn-danger' : ''}">
                                    ${u.isActive ? 'Block' : 'Unblock'}
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
