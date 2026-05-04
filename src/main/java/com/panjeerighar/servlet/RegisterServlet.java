package com.panjeerighar.servlet;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName").trim();
        String email    = request.getParameter("email").trim().toLowerCase();
        String phone    = request.getParameter("phone").trim();
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirmPassword");

        // Basic validation
        if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirm)) {
            request.setAttribute("error", "Passwords do not match.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // Check if email already exists
            String checkSql = "SELECT user_id FROM users WHERE email = ?";
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setString(1, email);
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    request.setAttribute("error", "An account with this email already exists.");
                    request.setAttribute("fullName", fullName);
                    request.setAttribute("email", email);
                    request.setAttribute("phone", phone);
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }
            }

            // Hash password and insert user
            String hash = BCrypt.hashpw(password, BCrypt.gensalt());
            String insertSql = "INSERT INTO users (full_name, email, phone, password_hash) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                stmt.setString(1, fullName);
                stmt.setString(2, email);
                stmt.setString(3, phone);
                stmt.setString(4, hash);
                stmt.executeUpdate();
            }

        } catch (SQLException e) {
            getServletContext().log("RegisterServlet DB Error: " + e.getMessage(), e);
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/login?registered=true");
    }
}
