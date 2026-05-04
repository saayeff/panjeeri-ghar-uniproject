package com.panjeerighar.servlet;

import com.panjeerighar.model.User;
import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/my-orders")
public class MyOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");

        // If a specific order is requested, load its items too
        String orderIdParam = request.getParameter("orderId");

        List<Map<String, Object>> orders = new ArrayList<>();
        String orderSql = "SELECT order_id, total_amount, shipping_amount, final_amount, " +
                          "shipping_address, shipping_city, shipping_state, shipping_pincode, " +
                          "order_status, payment_status, created_at " +
                          "FROM orders WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(orderSql)) {

            stmt.setInt(1, user.getUserId());
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> order = new LinkedHashMap<>();
                order.put("orderId",       rs.getInt("order_id"));
                order.put("subtotal",      rs.getBigDecimal("total_amount"));
                order.put("shipping",      rs.getBigDecimal("shipping_amount"));
                order.put("finalAmount",   rs.getBigDecimal("final_amount"));
                order.put("address",       rs.getString("shipping_address"));
                order.put("city",          rs.getString("shipping_city"));
                order.put("state",         rs.getString("shipping_state"));
                order.put("pincode",       rs.getString("shipping_pincode"));
                order.put("orderStatus",   rs.getString("order_status"));
                order.put("paymentStatus", rs.getString("payment_status"));
                order.put("createdAt",     rs.getTimestamp("created_at"));

                // Load items for this order
                List<Map<String, Object>> items = new ArrayList<>();
                String itemSql = "SELECT product_name, product_price, quantity, subtotal FROM order_items WHERE order_id = ?";
                try (PreparedStatement iStmt = conn.prepareStatement(itemSql)) {
                    iStmt.setInt(1, rs.getInt("order_id"));
                    ResultSet ir = iStmt.executeQuery();
                    while (ir.next()) {
                        Map<String, Object> item = new LinkedHashMap<>();
                        item.put("name",     ir.getString("product_name"));
                        item.put("price",    ir.getBigDecimal("product_price"));
                        item.put("quantity", ir.getInt("quantity"));
                        item.put("subtotal", ir.getBigDecimal("subtotal"));
                        items.add(item);
                    }
                }
                order.put("items", items);
                orders.add(order);
            }

        } catch (SQLException e) {
            getServletContext().log("MyOrdersServlet Error: " + e.getMessage(), e);
        }

        request.setAttribute("orders", orders);
        request.setAttribute("expandOrderId", orderIdParam);
        request.getRequestDispatcher("/my-orders.jsp").forward(request, response);
    }
}
