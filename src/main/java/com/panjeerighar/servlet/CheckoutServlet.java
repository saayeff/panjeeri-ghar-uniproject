package com.panjeerighar.servlet;

import com.panjeerighar.model.CartItem;
import com.panjeerighar.model.User;
import com.panjeerighar.util.DBConnection;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final BigDecimal SHIPPING_AMOUNT = new BigDecimal("0.00");
    private static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("0.00");
    private static final String RAZORPAY_KEY_ID     = System.getenv("RAZORPAY_KEY_ID");
    private static final String RAZORPAY_KEY_SECRET = System.getenv("RAZORPAY_KEY_SECRET");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request, response);
        if (user == null) return;

        List<CartItem> items = getCartItems(user.getUserId());

        if (items.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal subtotal = items.stream()
                .map(CartItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal shipping = subtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0
                ? BigDecimal.ZERO : SHIPPING_AMOUNT;

        BigDecimal total = subtotal.add(shipping);

        // Pre-fill address from user profile
        String address = "", city = "", state = "", pincode = "";
        String sql = "SELECT address, city, state, pincode FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, user.getUserId());
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                address = rs.getString("address") != null ? rs.getString("address") : "";
                city    = rs.getString("city")    != null ? rs.getString("city")    : "";
                state   = rs.getString("state")   != null ? rs.getString("state")   : "";
                pincode = rs.getString("pincode") != null ? rs.getString("pincode") : "";
            }
        } catch (SQLException e) {
            getServletContext().log("CheckoutServlet GET Error: " + e.getMessage(), e);
        }

        request.setAttribute("cartItems", items);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("shippingAmount", shipping);
        request.setAttribute("orderTotal", total);
        request.setAttribute("prefillAddress", address);
        request.setAttribute("prefillCity", city);
        request.setAttribute("prefillState", state);
        request.setAttribute("prefillPincode", pincode);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request, response);
        if (user == null) return;

        String address = request.getParameter("address").trim();
        String city    = request.getParameter("city").trim();
        String state   = request.getParameter("state").trim();
        String pincode = request.getParameter("pincode").trim();
        String notes   = request.getParameter("notes") != null ? request.getParameter("notes").trim() : "";

        if (address.isEmpty() || city.isEmpty() || state.isEmpty() || pincode.isEmpty()) {
            request.setAttribute("error", "Please fill in all address fields.");
            doGet(request, response);
            return;
        }

        List<CartItem> items = getCartItems(user.getUserId());
        if (items.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal subtotal = items.stream()
                .map(CartItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal shipping = subtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0
                ? BigDecimal.ZERO : SHIPPING_AMOUNT;

        BigDecimal total = subtotal.add(shipping);

        int orderId = -1;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Insert order
                String orderSql = "INSERT INTO orders (user_id, total_amount, shipping_amount, final_amount, " +
                                  "shipping_address, shipping_city, shipping_state, shipping_pincode, notes) " +
                                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setInt(1, user.getUserId());
                    stmt.setBigDecimal(2, subtotal);
                    stmt.setBigDecimal(3, shipping);
                    stmt.setBigDecimal(4, total);
                    stmt.setString(5, address);
                    stmt.setString(6, city);
                    stmt.setString(7, state);
                    stmt.setString(8, pincode);
                    stmt.setString(9, notes);
                    stmt.executeUpdate();
                    ResultSet keys = stmt.getGeneratedKeys();
                    if (keys.next()) orderId = keys.getInt(1);
                }

                // Insert order items
                String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, subtotal) " +
                                 "VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(itemSql)) {
                    for (CartItem item : items) {
                        stmt.setInt(1, orderId);
                        stmt.setInt(2, item.getProductId());
                        stmt.setString(3, item.getName());
                        stmt.setBigDecimal(4, item.getPrice());
                        stmt.setInt(5, item.getQuantity());
                        stmt.setBigDecimal(6, item.getSubtotal());
                        stmt.addBatch();
                    }
                    stmt.executeBatch();
                }

                // Clear cart
                String clearSql = "DELETE FROM cart WHERE user_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(clearSql)) {
                    stmt.setInt(1, user.getUserId());
                    stmt.executeUpdate();
                }

                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            getServletContext().log("CheckoutServlet POST Error: " + e.getMessage(), e);
            request.setAttribute("error", "Failed to place order. Please try again.");
            doGet(request, response);
            return;
        }

        // Create Razorpay order
        String razorpayOrderId;
        try {
            RazorpayClient razorpay = new RazorpayClient(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET);
            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", total.multiply(new BigDecimal("100")).intValue()); // paise
            orderRequest.put("currency", "INR");
            orderRequest.put("receipt", "order_" + orderId);
            Order rzpOrder = razorpay.orders.create(orderRequest);
            razorpayOrderId = rzpOrder.get("id");

            // Save razorpay_order_id to DB
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(
                         "UPDATE orders SET razorpay_order_id = ? WHERE order_id = ?")) {
                stmt.setString(1, razorpayOrderId);
                stmt.setInt(2, orderId);
                stmt.executeUpdate();
            }

        } catch (RazorpayException | SQLException e) {
            getServletContext().log("CheckoutServlet Razorpay Error: " + e.getMessage(), e);
            request.setAttribute("error", "Payment gateway error. Please try again.");
            doGet(request, response);
            return;
        }

        // Forward to payment page
        request.setAttribute("razorpayOrderId", razorpayOrderId);
        request.setAttribute("razorpayKeyId", RAZORPAY_KEY_ID);
        request.setAttribute("orderId", orderId);
        request.setAttribute("amount", total.multiply(new BigDecimal("100")).intValue());
        request.setAttribute("userEmail", user.getEmail());
        request.setAttribute("userPhone", user.getPhone());
        request.setAttribute("userName", user.getFullName());
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    private List<CartItem> getCartItems(int userId) {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT c.cart_id, c.product_id, c.quantity, p.name, p.price, p.image_url " +
                     "FROM cart c JOIN products p ON c.product_id = p.product_id WHERE c.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
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
                items.add(item);
            }
        } catch (SQLException e) {
            getServletContext().log("CheckoutServlet getCartItems Error: " + e.getMessage(), e);
        }
        return items;
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
