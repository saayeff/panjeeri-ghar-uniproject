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
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/auth/google/callback")
public class GoogleCallbackServlet extends HttpServlet {

    private static final HttpClient HTTP = HttpClient.newHttpClient();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── CSRF check ──
        String returnedState = request.getParameter("state");
        HttpSession session  = request.getSession(false);
        String savedState    = session != null ? (String) session.getAttribute("oauthState") : null;

        if (savedState == null || !savedState.equals(returnedState)) {
            response.sendRedirect(request.getContextPath() + "/login?error=oauth_state");
            return;
        }
        session.removeAttribute("oauthState");

        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login?error=oauth_denied");
            return;
        }

        try {
            // ── Exchange code for access token ──
            String tokenBody = "code="          + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id="     + URLEncoder.encode(GoogleAuthServlet.CLIENT_ID,     StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(GoogleAuthServlet.CLIENT_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri="  + URLEncoder.encode(GoogleAuthServlet.REDIRECT_URI,  StandardCharsets.UTF_8)
                + "&grant_type=authorization_code";

            HttpRequest tokenReq = HttpRequest.newBuilder()
                .uri(URI.create("https://oauth2.googleapis.com/token"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(tokenBody))
                .build();

            HttpResponse<String> tokenRes = HTTP.send(tokenReq, HttpResponse.BodyHandlers.ofString());
            String accessToken = extractJson(tokenRes.body(), "access_token");

            if (accessToken == null) {
                getServletContext().log("Google OAuth token error: " + tokenRes.body());
                response.sendRedirect(request.getContextPath() + "/login?error=oauth_token");
                return;
            }

            // ── Fetch user info ──
            HttpRequest userReq = HttpRequest.newBuilder()
                .uri(URI.create("https://www.googleapis.com/oauth2/v3/userinfo"))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

            HttpResponse<String> userRes = HTTP.send(userReq, HttpResponse.BodyHandlers.ofString());
            String googleId = extractJson(userRes.body(), "sub");
            String email    = extractJson(userRes.body(), "email");
            String name     = extractJson(userRes.body(), "name");

            if (googleId == null || email == null) {
                response.sendRedirect(request.getContextPath() + "/login?error=oauth_userinfo");
                return;
            }

            email = email.toLowerCase();

            // ── Find or create user ──
            User user = findOrCreateUser(googleId, email, name);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login?error=oauth_db");
                return;
            }

            // Google login = already authenticated — skip OTP, create full session
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("loggedInUser", user);
            newSession.setMaxInactiveInterval(60 * 60);

        } catch (Exception e) {
            getServletContext().log("GoogleCallbackServlet error: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/login?error=oauth_error");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/home");
    }

    // ── Find existing user by google_id or email, or create new account ──
    private User findOrCreateUser(String googleId, String email, String name) {
        try (Connection conn = DBConnection.getConnection()) {

            // Try by google_id first
            String sel = "SELECT user_id, full_name, email, phone, role FROM users WHERE google_id = ? OR email = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setString(1, googleId);
                ps.setString(2, email);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // Link google_id if not yet linked
                    try (PreparedStatement upd = conn.prepareStatement(
                            "UPDATE users SET google_id = ? WHERE user_id = ? AND google_id IS NULL")) {
                        upd.setString(1, googleId);
                        upd.setInt(2, rs.getInt("user_id"));
                        upd.executeUpdate();
                    }
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setRole(rs.getString("role"));
                    return u;
                }
            }

            // New user — create account (no password, Google-only)
            String ins = "INSERT INTO users (full_name, email, google_id, phone, password_hash, role, is_active) " +
                         "VALUES (?, ?, ?, '', '', 'customer', 1)";
            try (PreparedStatement ps = conn.prepareStatement(ins, new String[]{"user_id"})) {
                ps.setString(1, name != null ? name : email);
                ps.setString(2, email);
                ps.setString(3, googleId);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    User u = new User();
                    u.setUserId(keys.getInt(1));
                    u.setFullName(name != null ? name : email);
                    u.setEmail(email);
                    u.setPhone("");
                    u.setRole("customer");
                    return u;
                }
            }

        } catch (SQLException e) {
            getServletContext().log("GoogleCallbackServlet DB error: " + e.getMessage(), e);
        }
        return null;
    }

    // ── Minimal JSON string value extractor (no external lib needed) ──
    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;
        idx += search.length();
        // skip whitespace and colon
        while (idx < json.length() && (json.charAt(idx) == ' ' || json.charAt(idx) == ':')) idx++;
        if (idx >= json.length()) return null;
        char first = json.charAt(idx);
        if (first == '"') {
            // string value
            int start = idx + 1;
            int end = json.indexOf('"', start);
            return end < 0 ? null : json.substring(start, end);
        }
        // non-string (number, bool) — read until delimiter
        int start = idx;
        while (idx < json.length() && ",}\n\r ".indexOf(json.charAt(idx)) < 0) idx++;
        return json.substring(start, idx).trim();
    }
}
