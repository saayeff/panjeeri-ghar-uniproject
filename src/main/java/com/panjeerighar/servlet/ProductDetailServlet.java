package com.panjeerighar.servlet;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/product")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int productId = Integer.parseInt(idParam);
        String sql = "SELECT p.*, c.name AS category_name FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ? AND p.is_active = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();

            if (!rs.next()) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            Map<String, Object> product = new LinkedHashMap<>();
            product.put("productId",    rs.getInt("product_id"));
            product.put("categoryId",   rs.getInt("category_id"));
            product.put("categoryName", rs.getString("category_name"));
            product.put("name",         rs.getString("name"));
            product.put("description",  rs.getString("description"));
            product.put("weightGrams",  rs.getInt("weight_grams"));
            product.put("price",        rs.getBigDecimal("price"));
            product.put("mrp",          rs.getBigDecimal("mrp"));
            product.put("stockQty",     rs.getInt("stock_qty"));
            product.put("expiryDate",   rs.getDate("expiry_date"));
            product.put("batchNumber",  rs.getString("batch_number"));
            product.put("imageUrl",     rs.getString("image_url"));
            product.put("ingredients",  rs.getString("ingredients"));

            request.setAttribute("product", product);

        } catch (SQLException e) {
            getServletContext().log("ProductDetailServlet Error: " + e.getMessage(), e);
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
    }
}
