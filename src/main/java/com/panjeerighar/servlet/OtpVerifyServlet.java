package com.panjeerighar.servlet;

import com.panjeerighar.model.User;
import com.panjeerighar.util.DBConnection;
import com.panjeerighar.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.Random;

@WebServlet("/otp-verify")
public class OtpVerifyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingOtpUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("resend".equals(action)) {
            handleResend(request, response);
            return;
        }

        // ── Verify submitted OTP ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingOtpUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("pendingOtpUserId");
        String submitted = request.getParameter("otp");
        if (submitted == null) submitted = "";
        submitted = submitted.trim();

        try (Connection conn = DBConnection.getConnection()) {
            // Fetch stored OTP and expiry
            String sel = "SELECT otp_code, otp_expiry, full_name, email, phone, role FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                    session.invalidate();
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                String storedOtp   = rs.getString("otp_code");
                Timestamp expiry   = rs.getTimestamp("otp_expiry");

                if (storedOtp == null || expiry == null) {
                    request.setAttribute("error", "OTP not found. Please log in again.");
                    request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
                    return;
                }

                if (LocalDateTime.now().isAfter(expiry.toLocalDateTime())) {
                    clearOtp(conn, userId);
                    request.setAttribute("error", "OTP has expired. Please log in again.");
                    request.setAttribute("expired", true);
                    request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
                    return;
                }

                if (!storedOtp.equals(submitted)) {
                    request.setAttribute("error", "Incorrect code. Please try again.");
                    request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
                    return;
                }

                // OTP correct — clear it and create full session
                clearOtp(conn, userId);

                User user = new User();
                user.setUserId(userId);
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setRole(rs.getString("role"));

                session.removeAttribute("pendingOtpUserId");
                session.removeAttribute("pendingOtpEmail");
                session.setAttribute("loggedInUser", user);
                session.setMaxInactiveInterval(60 * 60);
            }
        } catch (SQLException e) {
            getServletContext().log("OtpVerifyServlet DB Error: " + e.getMessage(), e);
            request.setAttribute("error", "Verification failed. Please try again.");
            request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/home");
    }

    // ── Resend OTP ──
    private void handleResend(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingOtpUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("pendingOtpUserId");

        try (Connection conn = DBConnection.getConnection()) {
            String sel = "SELECT full_name, email FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }
                String name  = rs.getString("full_name");
                String email = rs.getString("email");

                String otp = generateOtp();
                storeOtp(conn, userId, otp);
                EmailService.sendOtp(email, name, otp);

                request.setAttribute("info", "A new code has been sent to your email.");
            }
        } catch (Exception e) {
            getServletContext().log("OtpVerifyServlet Resend Error: " + e.getMessage(), e);
            request.setAttribute("error", "Could not resend OTP. Please try again.");
        }

        request.getRequestDispatcher("/otp-verify.jsp").forward(request, response);
    }

    // ── Helpers ──
    public static String generateOtp() {
        return String.format("%06d", new Random().nextInt(1_000_000));
    }

    public static void storeOtp(Connection conn, int userId, String otp) throws SQLException {
        String upd = "UPDATE users SET otp_code = ?, otp_expiry = ? WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(upd)) {
            ps.setString(1, otp);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now().plusMinutes(5)));
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    private void clearOtp(Connection conn, int userId) throws SQLException {
        String upd = "UPDATE users SET otp_code = NULL, otp_expiry = NULL WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(upd)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
