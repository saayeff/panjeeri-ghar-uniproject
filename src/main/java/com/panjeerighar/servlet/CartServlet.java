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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request, response);
        if (user == null) return;

        String action = request.getParameter("action");

        if ("remove".equals(action)) {
            int cartId = Integer.parseInt(request.getParameter("cartId"));
            removeItem(cartId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        // Default: show cart
        List<CartItem> items = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        String sql = "SELECT c.cart_id, c.product_id, c.quantity, " +
                     "p.name, p.price, p.image_url " +
                     "FROM cart c JOIN products p ON c.product_id = p.product_id " +
                     "WHERE c.user_id = ? ORDER BY c.added_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, user.getUserId());
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                CartItem item = new CartItem();
                item.setCartId(rs.getInt("cart_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setName(rs.getString("name"));
                item.setImageUrl(rs.getString("image_url"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setQuantity(rs.getInt("quantity"));
                item.setSubtotal(rs.getBigDecimal("price").multiply(BigDecimal.valueOf(rs.getInt("quantity"))));
                total = total.add(item.getSubtotal());
                items.add(item);
            }

        } catch (SQLException e) {
            getServletContext().log("CartServlet DB Error: " + e.getMessage(), e);
        }

        request.setAttribute("cartItems", items);
        request.setAttribute("cartTotal", total);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request, response);
        if (user == null) return;

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity  = 1;
            try { quantity = Integer.parseInt(request.getParameter("quantity")); } catch (Exception ignored) {}

            addToCart(user.getUserId(), productId, quantity);

            String redirect = request.getParameter("buyNow");
            if ("true".equals(redirect)) {
                response.sendRedirect(request.getContextPath() + "/cart");
            } else {
                response.sendRedirect(request.getContextPath() + "/home?added=true");
            }

        } else if ("update".equals(action)) {
            int cartId  = Integer.parseInt(request.getParameter("cartId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            if (quantity <= 0) {
                removeItem(cartId, user.getUserId());
            } else {
                updateQuantity(cartId, user.getUserId(), quantity);
            }
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void addToCart(int userId, int productId, int quantity) {
        String checkSql = "SELECT cart_id, quantity FROM cart WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {

            check.setInt(1, userId);
            check.setInt(2, productId);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                // Already in cart — increment quantity
                int newQty = rs.getInt("quantity") + quantity;
                int cartId = rs.getInt("cart_id");
                String updateSql = "UPDATE cart SET quantity = ? WHERE cart_id = ?";
                try (PreparedStatement upd = conn.prepareStatement(updateSql)) {
                    upd.setInt(1, newQty);
                    upd.setInt(2, cartId);
                    upd.executeUpdate();
                }
            } else {
                String insertSql = "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)";
                try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
                    ins.setInt(1, userId);
                    ins.setInt(2, productId);
                    ins.setInt(3, quantity);
                    ins.executeUpdate();
                }
            }

        } catch (SQLException e) {
            getServletContext().log("CartServlet addToCart Error: " + e.getMessage(), e);
        }
    }

    private void removeItem(int cartId, int userId) {
        String sql = "DELETE FROM cart WHERE cart_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, cartId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("CartServlet removeItem Error: " + e.getMessage(), e);
        }
    }

    private void updateQuantity(int cartId, int userId, int quantity) {
        String sql = "UPDATE cart SET quantity = ? WHERE cart_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, cartId);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("CartServlet updateQuantity Error: " + e.getMessage(), e);
        }
    }

    private User getLoggedInUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("loggedInUser");
    }
}
