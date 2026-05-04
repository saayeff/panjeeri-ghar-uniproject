package com.panjeerighar.servlet;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/payment/verify")
public class PaymentVerificationServlet extends HttpServlet {

    private static final String RAZORPAY_KEY_SECRET = System.getenv("RAZORPAY_KEY_SECRET");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String razorpayOrderId   = request.getParameter("razorpay_order_id");
        String razorpayPaymentId = request.getParameter("razorpay_payment_id");
        String razorpaySignature = request.getParameter("razorpay_signature");
        int orderId = Integer.parseInt(request.getParameter("order_id"));

        boolean valid = verifySignature(razorpayOrderId, razorpayPaymentId, razorpaySignature);

        if (valid) {
            // Update order: paid + confirmed
            String sql = "UPDATE orders SET payment_status = 'paid', order_status = 'confirmed', " +
                         "razorpay_payment_id = ? WHERE order_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, razorpayPaymentId);
                stmt.setInt(2, orderId);
                stmt.executeUpdate();
            } catch (SQLException e) {
                getServletContext().log("PaymentVerificationServlet DB Error: " + e.getMessage(), e);
            }
            response.sendRedirect(request.getContextPath() + "/order-confirmation?orderId=" + orderId);
        } else {
            // Mark as failed
            String sql = "UPDATE orders SET payment_status = 'failed' WHERE order_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, orderId);
                stmt.executeUpdate();
            } catch (SQLException e) {
                getServletContext().log("PaymentVerificationServlet DB Error: " + e.getMessage(), e);
            }
            response.sendRedirect(request.getContextPath() + "/checkout?paymentFailed=true");
        }
    }

    private boolean verifySignature(String razorpayOrderId, String razorpayPaymentId, String signature) {
        try {
            String payload = razorpayOrderId + "|" + razorpayPaymentId;
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(RAZORPAY_KEY_SECRET.getBytes("UTF-8"), "HmacSHA256");
            mac.init(secretKey);
            byte[] hash = mac.doFinal(payload.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString().equals(signature);
        } catch (Exception e) {
            getServletContext().log("Signature verification error: " + e.getMessage(), e);
            return false;
        }
    }
}
