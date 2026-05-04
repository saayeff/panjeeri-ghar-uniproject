package com.panjeerighar.servlet.admin;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBConnection.getConnection()) {

            request.setAttribute("totalOrders",   queryInt(conn, "SELECT COUNT(*) FROM orders"));
            request.setAttribute("totalRevenue",  queryInt(conn, "SELECT COALESCE(SUM(final_amount),0) FROM orders WHERE payment_status='paid'"));
            request.setAttribute("totalProducts", queryInt(conn, "SELECT COUNT(*) FROM products WHERE is_active=1"));
            request.setAttribute("totalUsers",    queryInt(conn, "SELECT COUNT(*) FROM users"));
            request.setAttribute("pendingOrders", queryInt(conn, "SELECT COUNT(*) FROM orders WHERE order_status='pending'"));

            // Recent 5 orders
            String recentSql = "SELECT o.order_id, u.full_name, o.final_amount, o.order_status, " +
                               "o.payment_status, o.created_at " +
                               "FROM orders o JOIN users u ON o.user_id = u.user_id " +
                               "ORDER BY o.created_at DESC LIMIT 5";
            try (PreparedStatement stmt = conn.prepareStatement(recentSql);
                 ResultSet rs = stmt.executeQuery()) {
                java.util.List<java.util.Map<String, Object>> orders = new java.util.ArrayList<>();
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("orderId",       rs.getInt("order_id"));
                    row.put("customerName",  rs.getString("full_name"));
                    row.put("amount",        rs.getBigDecimal("final_amount"));
                    row.put("orderStatus",   rs.getString("order_status"));
                    row.put("paymentStatus", rs.getString("payment_status"));
                    row.put("createdAt",     rs.getTimestamp("created_at"));
                    orders.add(row);
                }
                request.setAttribute("recentOrders", orders);
            }

        } catch (SQLException e) {
            getServletContext().log("AdminDashboard Error: " + e.getMessage(), e);
        }

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private int queryInt(Connection conn, String sql) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}
