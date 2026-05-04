package com.panjeerighar.servlet;

import com.panjeerighar.model.Product;
import com.panjeerighar.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * HomeServlet — handles requests to the homepage "/"
 * Fetches all active products from MySQL and sends them to index.jsp
 * This is the MVC pattern: Servlet = Controller, JSP = View, Product = Model
 */
@WebServlet(urlPatterns = {"", "/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> products = new ArrayList<>();

        // Query: fetch all active products, order by FEFO (expiry_date ASC)
        String sql = "SELECT product_id, category_id, name, slug, description, " +
                     "weight_grams, price, mrp, stock_qty, expiry_date, " +
                     "batch_number, image_url, ingredients, is_active " +
                     "FROM products " +
                     "WHERE is_active = 1 " +
                     "ORDER BY expiry_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setWeightGrams(rs.getInt("weight_grams"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setMrp(rs.getBigDecimal("mrp"));
                p.setStockQty(rs.getInt("stock_qty"));
                p.setExpiryDate(rs.getDate("expiry_date"));
                p.setBatchNumber(rs.getString("batch_number"));
                p.setImageUrl(rs.getString("image_url"));
                p.setIngredients(rs.getString("ingredients"));
                p.setActive(rs.getBoolean("is_active"));
                products.add(p);
            }

        } catch (SQLException e) {
            getServletContext().log("HomeServlet DB Error: " + e.getMessage(), e);
            request.setAttribute("dbError", "Unable to load products: " + e.getMessage());
        }

        // Pass products list to JSP (the View)
        request.setAttribute("products", products);

        // Forward to index.jsp
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
