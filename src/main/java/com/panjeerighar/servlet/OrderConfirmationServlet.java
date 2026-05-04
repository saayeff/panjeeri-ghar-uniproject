package com.panjeerighar.servlet;

import com.panjeerighar.model.CartItem;
import com.panjeerighar.model.User;
import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/order-confirmation")
public class OrderConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");

        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int orderId = Integer.parseInt(orderIdParam);

        // Fetch order details
        String orderSql = "SELECT order_id, total_amount, shipping_amount, final_amount, " +
                          "shipping_address, shipping_city, shipping_state, shipping_pincode, " +
                          "order_status, payment_status, created_at " +
                          "FROM orders WHERE order_id = ? AND user_id = ?";

        String itemsSql = "SELECT product_name, product_price, quantity, subtotal FROM order_items WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection()) {

            try (PreparedStatement stmt = conn.prepareStatement(orderSql)) {
                stmt.setInt(1, orderId);
                stmt.setInt(2, user.getUserId());
                ResultSet rs = stmt.executeQuery();
                if (!rs.next()) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                request.setAttribute("orderId",       rs.getInt("order_id"));
                request.setAttribute("subtotal",      rs.getBigDecimal("total_amount"));
                request.setAttribute("shipping",      rs.getBigDecimal("shipping_amount"));
                request.setAttribute("finalAmount",   rs.getBigDecimal("final_amount"));
                request.setAttribute("shipAddress",   rs.getString("shipping_address"));
                request.setAttribute("shipCity",      rs.getString("shipping_city"));
                request.setAttribute("shipState",     rs.getString("shipping_state"));
                request.setAttribute("shipPincode",   rs.getString("shipping_pincode"));
                request.setAttribute("orderStatus",   rs.getString("order_status"));
                request.setAttribute("paymentStatus", rs.getString("payment_status"));
                request.setAttribute("createdAt",     rs.getTimestamp("created_at"));
            }

            List<CartItem> items = new ArrayList<>();
            try (PreparedStatement stmt = conn.prepareStatement(itemsSql)) {
                stmt.setInt(1, orderId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setName(rs.getString("product_name"));
                    item.setPrice(rs.getBigDecimal("product_price"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setSubtotal(rs.getBigDecimal("subtotal"));
                    items.add(item);
                }
            }
            request.setAttribute("orderItems", items);

        } catch (SQLException e) {
            getServletContext().log("OrderConfirmationServlet Error: " + e.getMessage(), e);
        }

        request.getRequestDispatcher("/order-confirmation.jsp").forward(request, response);
    }
}
