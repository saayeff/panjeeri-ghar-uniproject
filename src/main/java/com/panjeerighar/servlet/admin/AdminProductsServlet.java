package com.panjeerighar.servlet.admin;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/products")
public class AdminProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("id"));
            loadProductForEdit(request, productId);
            loadCategories(request);
            request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
            return;
        }

        if ("add".equals(action)) {
            loadCategories(request);
            request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("id"));
            String sql = "UPDATE products SET is_active = 0 WHERE product_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, productId);
                stmt.executeUpdate();
            } catch (SQLException e) {
                getServletContext().log("AdminProducts Delete Error: " + e.getMessage(), e);
            }
            response.sendRedirect(request.getContextPath() + "/admin/products?deleted=true");
            return;
        }

        // List all products
        List<Map<String, Object>> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.price, p.mrp, p.stock_qty, " +
                     "p.is_active, p.weight_grams, c.name AS category_name " +
                     "FROM products p LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "ORDER BY p.product_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("productId",    rs.getInt("product_id"));
                row.put("name",         rs.getString("name"));
                row.put("price",        rs.getBigDecimal("price"));
                row.put("mrp",          rs.getBigDecimal("mrp"));
                row.put("stockQty",     rs.getInt("stock_qty"));
                row.put("isActive",     rs.getBoolean("is_active"));
                row.put("weightGrams",  rs.getInt("weight_grams"));
                row.put("categoryName", rs.getString("category_name"));
                products.add(row);
            }

        } catch (SQLException e) {
            getServletContext().log("AdminProducts List Error: " + e.getMessage(), e);
        }

        request.setAttribute("products", products);
        request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action    = request.getParameter("action");
        String name      = request.getParameter("name").trim();
        String slug      = name.toLowerCase().replaceAll("[^a-z0-9]+", "-");
        int categoryId   = Integer.parseInt(request.getParameter("categoryId"));
        String desc      = request.getParameter("description").trim();
        int weightGrams  = Integer.parseInt(request.getParameter("weightGrams"));
        BigDecimal price = new BigDecimal(request.getParameter("price"));
        BigDecimal mrp   = new BigDecimal(request.getParameter("mrp"));
        int stockQty     = Integer.parseInt(request.getParameter("stockQty"));
        String expiryDate   = request.getParameter("expiryDate");
        String batchNumber  = request.getParameter("batchNumber").trim();
        String imageUrl     = request.getParameter("imageUrl").trim();
        String ingredients  = request.getParameter("ingredients").trim();
        boolean isActive    = "on".equals(request.getParameter("isActive"));

        try (Connection conn = DBConnection.getConnection()) {

            if ("add".equals(action)) {
                String sql = "INSERT INTO products (category_id, name, slug, description, weight_grams, " +
                             "price, mrp, stock_qty, expiry_date, batch_number, image_url, ingredients, is_active) " +
                             "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, categoryId);
                    stmt.setString(2, name);
                    stmt.setString(3, slug);
                    stmt.setString(4, desc);
                    stmt.setInt(5, weightGrams);
                    stmt.setBigDecimal(6, price);
                    stmt.setBigDecimal(7, mrp);
                    stmt.setInt(8, stockQty);
                    stmt.setDate(9, Date.valueOf(expiryDate));
                    stmt.setString(10, batchNumber);
                    stmt.setString(11, imageUrl);
                    stmt.setString(12, ingredients);
                    stmt.setBoolean(13, isActive);
                    stmt.executeUpdate();
                }

            } else if ("edit".equals(action)) {
                int productId = Integer.parseInt(request.getParameter("productId"));
                String sql = "UPDATE products SET category_id=?, name=?, slug=?, description=?, weight_grams=?, " +
                             "price=?, mrp=?, stock_qty=?, expiry_date=?, batch_number=?, image_url=?, " +
                             "ingredients=?, is_active=? WHERE product_id=?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, categoryId);
                    stmt.setString(2, name);
                    stmt.setString(3, slug);
                    stmt.setString(4, desc);
                    stmt.setInt(5, weightGrams);
                    stmt.setBigDecimal(6, price);
                    stmt.setBigDecimal(7, mrp);
                    stmt.setInt(8, stockQty);
                    stmt.setDate(9, Date.valueOf(expiryDate));
                    stmt.setString(10, batchNumber);
                    stmt.setString(11, imageUrl);
                    stmt.setString(12, ingredients);
                    stmt.setBoolean(13, isActive);
                    stmt.setInt(14, productId);
                    stmt.executeUpdate();
                }
            }

        } catch (SQLException e) {
            getServletContext().log("AdminProducts Save Error: " + e.getMessage(), e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/products?saved=true");
    }

    private void loadProductForEdit(HttpServletRequest request, int productId) {
        String sql = "SELECT * FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                request.setAttribute("editProduct", rs);
                Map<String, Object> p = new LinkedHashMap<>();
                p.put("productId",   rs.getInt("product_id"));
                p.put("categoryId",  rs.getInt("category_id"));
                p.put("name",        rs.getString("name"));
                p.put("description", rs.getString("description"));
                p.put("weightGrams", rs.getInt("weight_grams"));
                p.put("price",       rs.getBigDecimal("price"));
                p.put("mrp",         rs.getBigDecimal("mrp"));
                p.put("stockQty",    rs.getInt("stock_qty"));
                p.put("expiryDate",  rs.getDate("expiry_date"));
                p.put("batchNumber", rs.getString("batch_number"));
                p.put("imageUrl",    rs.getString("image_url"));
                p.put("ingredients", rs.getString("ingredients"));
                p.put("isActive",    rs.getBoolean("is_active"));
                request.setAttribute("product", p);
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProducts LoadEdit Error: " + e.getMessage(), e);
        }
    }

    private void loadCategories(HttpServletRequest request) {
        List<Map<String, Object>> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM categories WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> c = new LinkedHashMap<>();
                c.put("categoryId", rs.getInt("category_id"));
                c.put("name",       rs.getString("name"));
                categories.add(c);
            }
        } catch (SQLException e) {
            getServletContext().log("AdminProducts LoadCategories Error: " + e.getMessage(), e);
        }
        request.setAttribute("categories", categories);
    }
}
