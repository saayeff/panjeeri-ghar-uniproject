package com.panjeerighar.servlet.admin;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/order-detail")
public class AdminOrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        int orderId = Integer.parseInt(idParam);

        try (Connection conn = DBConnection.getConnection()) {

            // Order header
            String orderSql =
                "SELECT o.*, u.full_name, u.email, u.phone " +
                "FROM orders o JOIN users u ON o.user_id = u.user_id " +
                "WHERE o.order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                    response.sendRedirect(request.getContextPath() + "/admin/orders");
                    return;
                }
                Map<String, Object> order = new LinkedHashMap<>();
                order.put("orderId",         rs.getInt("order_id"));
                order.put("customerName",    rs.getString("full_name"));
                order.put("email",           rs.getString("email"));
                order.put("phone",           rs.getString("phone"));
                order.put("orderStatus",     rs.getString("order_status"));
                order.put("paymentStatus",   rs.getString("payment_status"));
                order.put("paymentMethod",   rs.getString("payment_method"));
                order.put("subtotal",        rs.getBigDecimal("subtotal"));
                order.put("discountAmount",  rs.getBigDecimal("discount_amount"));
                order.put("shippingCharge",  rs.getBigDecimal("shipping_charge"));
                order.put("finalAmount",     rs.getBigDecimal("final_amount"));
                order.put("shippingName",    rs.getString("shipping_name"));
                order.put("shippingPhone",   rs.getString("shipping_phone"));
                order.put("shippingAddress", rs.getString("shipping_address"));
                order.put("shippingCity",    rs.getString("shipping_city"));
                order.put("shippingState",   rs.getString("shipping_state"));
                order.put("shippingPincode", rs.getString("shipping_pincode"));
                order.put("notes",           rs.getString("notes"));
                order.put("createdAt",       rs.getTimestamp("created_at"));
                request.setAttribute("order", order);
            }

            // Order items
            String itemsSql =
                "SELECT oi.quantity, oi.unit_price, oi.total_price, p.name, p.image_url, p.weight_grams " +
                "FROM order_items oi JOIN products p ON oi.product_id = p.product_id " +
                "WHERE oi.order_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(itemsSql)) {
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                List<Map<String, Object>> items = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("name",        rs.getString("name"));
                    item.put("imageUrl",    rs.getString("image_url"));
                    item.put("weightGrams", rs.getInt("weight_grams"));
                    item.put("quantity",    rs.getInt("quantity"));
                    item.put("unitPrice",   rs.getBigDecimal("unit_price"));
                    item.put("totalPrice",  rs.getBigDecimal("total_price"));
                    items.add(item);
                }
                request.setAttribute("items", items);
            }

        } catch (SQLException e) {
            getServletContext().log("AdminOrderDetail Error: " + e.getMessage(), e);
        }

        request.getRequestDispatcher("/admin/order-detail.jsp").forward(request, response);
    }
}
