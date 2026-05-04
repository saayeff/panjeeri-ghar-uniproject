package com.panjeerighar.servlet.admin;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class AdminOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String filter = request.getParameter("status");
        String q      = request.getParameter("q");
        if (q != null) q = q.trim();
        List<Map<String, Object>> orders = new ArrayList<>();

        String sql = "SELECT o.order_id, u.full_name, u.email, u.phone, " +
                     "o.final_amount, o.order_status, o.payment_status, o.created_at, " +
                     "o.shipping_city, o.shipping_state " +
                     "FROM orders o JOIN users u ON o.user_id = u.user_id WHERE 1=1";
        if (filter != null && !filter.isEmpty()) sql += " AND o.order_status = ?";
        if (q != null && !q.isEmpty())           sql += " AND (u.full_name LIKE ? OR u.email LIKE ? OR CAST(o.order_id AS CHAR) LIKE ?)";
        sql += " ORDER BY o.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            int idx = 1;
            if (filter != null && !filter.isEmpty()) stmt.setString(idx++, filter);
            if (q != null && !q.isEmpty()) {
                String like = "%" + q + "%";
                stmt.setString(idx++, like);
                stmt.setString(idx++, like);
                stmt.setString(idx,   like);
            }
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("orderId",       rs.getInt("order_id"));
                row.put("customerName",  rs.getString("full_name"));
                row.put("email",         rs.getString("email"));
                row.put("phone",         rs.getString("phone"));
                row.put("amount",        rs.getBigDecimal("final_amount"));
                row.put("orderStatus",   rs.getString("order_status"));
                row.put("paymentStatus", rs.getString("payment_status"));
                row.put("createdAt",     rs.getTimestamp("created_at"));
                row.put("city",          rs.getString("shipping_city"));
                row.put("state",         rs.getString("shipping_state"));
                orders.add(row);
            }

        } catch (SQLException e) {
            getServletContext().log("AdminOrders Error: " + e.getMessage(), e);
        }

        request.setAttribute("orders", orders);
        request.setAttribute("selectedStatus", filter);
        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String newStatus = request.getParameter("orderStatus");

        String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setInt(2, orderId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("AdminOrders Update Error: " + e.getMessage(), e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders?updated=true");
    }
}
