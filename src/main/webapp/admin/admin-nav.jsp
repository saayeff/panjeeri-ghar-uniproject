<%-- Shared admin sidebar nav — NO taglib declaration here (parent pages declare it) --%>
<%
    String _uri = request.getRequestURI();
    String _ctx = request.getContextPath();
%>
<div class="admin-sidebar">
    <a href="<%= _ctx %>/admin/dashboard" class="brand">
        Panjeeri Ghar
        <span>Admin Panel</span>
    </a>
    <nav>
        <a href="<%= _ctx %>/admin/dashboard" class="<%= _uri.contains("/dashboard") ? "active" : "" %>">Dashboard</a>
        <a href="<%= _ctx %>/admin/orders"    class="<%= _uri.contains("/orders")    ? "active" : "" %>">Orders</a>
        <a href="<%= _ctx %>/admin/products"  class="<%= _uri.contains("/products")  ? "active" : "" %>">Products</a>
        <a href="<%= _ctx %>/admin/users"     class="<%= _uri.contains("/users")     ? "active" : "" %>">Users</a>
        <a href="<%= _ctx %>/home" target="_blank">View Store &rarr;</a>
    </nav>
    <div class="sidebar-footer">
        <span style="color:#ffe0b2;font-size:0.82rem;display:block;margin-bottom:6px;">${sessionScope.loggedInUser.fullName}</span>
        <a href="<%= _ctx %>/logout">Logout</a>
    </div>
</div>
