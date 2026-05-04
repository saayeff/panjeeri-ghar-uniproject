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
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/cart-api")
public class CartApiServlet extends HttpServlet {

    /** GET /cart-api — return current cart as JSON */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        User user = getUser(request);
        if (user == null) {
            response.getWriter().write("{\"loggedIn\":false,\"items\":[],\"total\":\"0.00\",\"count\":0}");
            return;
        }
        writeCartJson(user.getUserId(), response.getWriter(), request.getContextPath());
    }

    /** POST /cart-api — action=add|update|remove, returns updated cart JSON */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        User user = getUser(request);
        if (user == null) {
            response.getWriter().write("{\"loggedIn\":false,\"items\":[],\"total\":\"0.00\",\"count\":0}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int quantity  = 1;
                try { quantity = Integer.parseInt(request.getParameter("quantity")); } catch (Exception ignored) {}
                addToCart(user.getUserId(), productId, quantity);

            } else if ("update".equals(action)) {
                int cartId  = Integer.parseInt(request.getParameter("cartId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity <= 0) {
                    removeItem(cartId, user.getUserId());
                } else {
                    updateQuantity(cartId, user.getUserId(), quantity);
                }

            } else if ("remove".equals(action)) {
                int cartId = Integer.parseInt(request.getParameter("cartId"));
                removeItem(cartId, user.getUserId());
            }
        } catch (NumberFormatException e) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"Bad request\"}");
            return;
        } catch (SQLException e) {
            getServletContext().log("CartApiServlet doPost error: " + e.getMessage(), e);
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Server error\"}");
            return;
        }

        writeCartJson(user.getUserId(), response.getWriter(), request.getContextPath());
    }

    // ─── helpers ────────────────────────────────────────────────────────────

    private void writeCartJson(int userId, PrintWriter out, String contextPath) {
        String sql = "SELECT c.cart_id, c.product_id, c.quantity, " +
                     "p.name, p.price, p.image_url, p.weight_grams " +
                     "FROM cart c JOIN products p ON c.product_id = p.product_id " +
                     "WHERE c.user_id = ? ORDER BY c.added_at DESC";

        StringBuilder sb = new StringBuilder();
        BigDecimal total = BigDecimal.ZERO;
        int count = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            sb.append("{\"loggedIn\":true,\"items\":[");
            boolean first = true;

            while (rs.next()) {
                BigDecimal price    = rs.getBigDecimal("price");
                int        qty      = rs.getInt("quantity");
                BigDecimal subtotal = price.multiply(BigDecimal.valueOf(qty));
                total = total.add(subtotal);
                count++;

                String imageUrl = rs.getString("image_url");
                String imgSrc   = (imageUrl != null && !imageUrl.isEmpty())
                                  ? contextPath + "/" + escJson(imageUrl)
                                  : "";
                String name = rs.getString("name");
                int weightGrams = rs.getInt("weight_grams");

                if (!first) sb.append(",");
                first = false;

                sb.append("{")
                  .append("\"cartId\":").append(rs.getInt("cart_id")).append(",")
                  .append("\"productId\":").append(rs.getInt("product_id")).append(",")
                  .append("\"name\":\"").append(escJson(name)).append("\",")
                  .append("\"weightGrams\":").append(weightGrams).append(",")
                  .append("\"price\":\"").append(price.toPlainString()).append("\",")
                  .append("\"quantity\":").append(qty).append(",")
                  .append("\"subtotal\":\"").append(subtotal.toPlainString()).append("\",")
                  .append("\"imageUrl\":\"").append(imgSrc).append("\"")
                  .append("}");
            }

        } catch (SQLException e) {
            getServletContext().log("CartApiServlet DB error: " + e.getMessage(), e);
        }

        sb.append("],")
          .append("\"total\":\"").append(total.toPlainString()).append("\",")
          .append("\"count\":").append(count)
          .append("}");

        out.write(sb.toString());
    }

    private void addToCart(int userId, int productId, int quantity) throws SQLException {
        String checkSql = "SELECT cart_id, quantity FROM cart WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setInt(1, userId);
            check.setInt(2, productId);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                int newQty  = rs.getInt("quantity") + quantity;
                int cartId  = rs.getInt("cart_id");
                try (PreparedStatement upd = conn.prepareStatement(
                        "UPDATE cart SET quantity = ? WHERE cart_id = ?")) {
                    upd.setInt(1, newQty);
                    upd.setInt(2, cartId);
                    upd.executeUpdate();
                }
            } else {
                try (PreparedStatement ins = conn.prepareStatement(
                        "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)")) {
                    ins.setInt(1, userId);
                    ins.setInt(2, productId);
                    ins.setInt(3, quantity);
                    ins.executeUpdate();
                }
            }
        }
    }

    private void removeItem(int cartId, int userId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "DELETE FROM cart WHERE cart_id = ? AND user_id = ?")) {
            stmt.setInt(1, cartId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }
    }

    private void updateQuantity(int cartId, int userId, int quantity) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "UPDATE cart SET quantity = ? WHERE cart_id = ? AND user_id = ?")) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, cartId);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        }
    }

    private User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("loggedInUser");
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
