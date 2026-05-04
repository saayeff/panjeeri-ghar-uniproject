package com.panjeerighar.servlet.admin;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        if (q != null) q = q.trim();
        List<Map<String, Object>> users = new ArrayList<>();

        String sql = "SELECT user_id, full_name, email, phone, role, is_active, created_at FROM users WHERE 1=1";
        if (q != null && !q.isEmpty()) sql += " AND (full_name LIKE ? OR email LIKE ?)";
        sql += " ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (q != null && !q.isEmpty()) {
                String like = "%" + q + "%";
                stmt.setString(1, like);
                stmt.setString(2, like);
            }
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("userId",    rs.getInt("user_id"));
                row.put("fullName",  rs.getString("full_name"));
                row.put("email",     rs.getString("email"));
                row.put("phone",     rs.getString("phone"));
                row.put("role",      rs.getString("role"));
                row.put("isActive",  rs.getBoolean("is_active"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                users.add(row);
            }

        } catch (SQLException e) {
            getServletContext().log("AdminUsers Error: " + e.getMessage(), e);
        }

        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId    = Integer.parseInt(request.getParameter("userId"));
        String action = request.getParameter("action");

        String sql = "toggle".equals(action)
                ? "UPDATE users SET is_active = NOT is_active WHERE user_id = ?"
                : "UPDATE users SET role = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if ("toggle".equals(action)) {
                stmt.setInt(1, userId);
            } else {
                stmt.setString(1, request.getParameter("role"));
                stmt.setInt(2, userId);
            }
            stmt.executeUpdate();

        } catch (SQLException e) {
            getServletContext().log("AdminUsers Update Error: " + e.getMessage(), e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/users?updated=true");
    }
}
