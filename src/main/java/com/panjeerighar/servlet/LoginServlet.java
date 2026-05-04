package com.panjeerighar.servlet;

import com.panjeerighar.util.DBConnection;
import com.panjeerighar.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email").trim().toLowerCase();
        String password = request.getParameter("password");

        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT user_id, full_name, email, password_hash, is_active " +
                     "FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (!rs.next()) {
                request.setAttribute("error", "Invalid email or password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if (!BCrypt.checkpw(password, rs.getString("password_hash"))) {
                request.setAttribute("error", "Invalid email or password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if (rs.getInt("is_active") == 0) {
                request.setAttribute("error", "Your account has been deactivated. Please contact support.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            int    userId   = rs.getInt("user_id");
            String fullName = rs.getString("full_name");

            // Generate OTP, store in DB, send email
            String otp = OtpVerifyServlet.generateOtp();
            OtpVerifyServlet.storeOtp(conn, userId, otp);
            EmailService.sendOtp(email, fullName, otp);

            // Store pending user ID in session — full session created only after OTP verified
            HttpSession session = request.getSession(true);
            session.setAttribute("pendingOtpUserId", userId);
            session.setAttribute("pendingOtpEmail",  email);
            session.setMaxInactiveInterval(10 * 60); // 10 minutes to complete OTP

        } catch (SQLException e) {
            getServletContext().log("LoginServlet DB Error: " + e.getMessage(), e);
            request.setAttribute("error", "Login failed. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        } catch (Exception e) {
            getServletContext().log("LoginServlet Email Error: " + e.getMessage(), e);
            request.setAttribute("error", "Could not send verification email. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/otp-verify");
    }
}
