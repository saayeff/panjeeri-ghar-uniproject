package com.panjeerighar.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet("/auth/google")
public class GoogleAuthServlet extends HttpServlet {

    static final String CLIENT_ID     = System.getenv("GOOGLE_CLIENT_ID");
    static final String CLIENT_SECRET = System.getenv("GOOGLE_CLIENT_SECRET");
    static final String REDIRECT_URI  = System.getenv("GOOGLE_REDIRECT_URI") != null
            ? System.getenv("GOOGLE_REDIRECT_URI")
            : "http://localhost:8080/panjeeri-ghar/auth/google/callback";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Generate CSRF state token
        byte[] bytes = new byte[16];
        new SecureRandom().nextBytes(bytes);
        String state = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        HttpSession session = request.getSession(true);
        session.setAttribute("oauthState", state);

        String authUrl = "https://accounts.google.com/o/oauth2/v2/auth"
            + "?client_id="     + URLEncoder.encode(CLIENT_ID,    StandardCharsets.UTF_8)
            + "&redirect_uri="  + URLEncoder.encode(REDIRECT_URI, StandardCharsets.UTF_8)
            + "&response_type=code"
            + "&scope="         + URLEncoder.encode("openid email profile", StandardCharsets.UTF_8)
            + "&state="         + URLEncoder.encode(state, StandardCharsets.UTF_8)
            + "&access_type=online";

        response.sendRedirect(authUrl);
    }
}
