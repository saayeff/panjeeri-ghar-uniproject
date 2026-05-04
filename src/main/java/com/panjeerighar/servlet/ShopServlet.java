package com.panjeerighar.servlet;

import com.panjeerighar.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/shop")
public class ShopServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String categorySlug = request.getParameter("category");
        String sort         = request.getParameter("sort");
        String q            = request.getParameter("q");
        if (q != null) q = q.trim();

        // Build query
        StringBuilder sql = new StringBuilder(
            "SELECT p.product_id, p.name, p.price, p.mrp, p.image_url, p.weight_grams, p.stock_qty, " +
            "c.name AS category_name, c.slug AS category_slug " +
            "FROM products p LEFT JOIN categories c ON p.category_id = c.category_id " +
            "WHERE p.is_active = 1"
        );

        List<Object> params = new ArrayList<>();

        if (categorySlug != null && !categorySlug.isEmpty()) {
            sql.append(" AND c.slug = ?");
            params.add(categorySlug);
        }
        if (q != null && !q.isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }

        if ("price-asc".equals(sort))  sql.append(" ORDER BY p.price ASC");
        else if ("price-desc".equals(sort)) sql.append(" ORDER BY p.price DESC");
        else if ("name".equals(sort))  sql.append(" ORDER BY p.name ASC");
        else                           sql.append(" ORDER BY p.product_id ASC");

        List<Map<String, Object>> products = new ArrayList<>();
        List<Map<String, Object>> categories = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            // Load categories for filter bar
            String catSql = "SELECT slug, name FROM categories WHERE is_active = 1 ORDER BY name";
            try (PreparedStatement ps = conn.prepareStatement(catSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> c = new LinkedHashMap<>();
                    c.put("slug", rs.getString("slug"));
                    c.put("name", rs.getString("name"));
                    categories.add(c);
                }
            }

            // Load products
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> p = new LinkedHashMap<>();
                    p.put("productId",    rs.getInt("product_id"));
                    p.put("name",         rs.getString("name"));
                    p.put("price",        rs.getBigDecimal("price"));
                    p.put("mrp",          rs.getBigDecimal("mrp"));
                    p.put("imageUrl",     rs.getString("image_url"));
                    p.put("weightGrams",  rs.getInt("weight_grams"));
                    p.put("stockQty",     rs.getInt("stock_qty"));
                    p.put("categoryName", rs.getString("category_name"));
                    products.add(p);
                }
            }

        } catch (SQLException e) {
            getServletContext().log("ShopServlet Error: " + e.getMessage(), e);
        }

        request.setAttribute("products",        products);
        request.setAttribute("categories",      categories);
        request.setAttribute("selectedCategory", categorySlug);
        request.setAttribute("selectedSort",    sort);
        request.setAttribute("q",               q);
        request.getRequestDispatcher("/shop.jsp").forward(request, response);
    }
}
