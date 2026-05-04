-- ============================================================
--  PANJEERI GHAR — Complete MySQL Database Schema
--  Project: E-Commerce Inventory Management System
--  Student: Shaikh Saifullah | BCA 6th Sem | OU
--  Stack: Java Servlet + JSP + MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS panjeeri_ghar;
USE panjeeri_ghar;

-- ============================================================
-- TABLE 1: users
-- Stores customer and admin accounts
-- ============================================================
CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)        NOT NULL,
    email         VARCHAR(150)        NOT NULL UNIQUE,
    phone         VARCHAR(15)         NOT NULL,
    password_hash VARCHAR(255)        NOT NULL,        -- BCrypt hashed, never plain text
    role          ENUM('customer','admin') DEFAULT 'customer',
    address       TEXT,
    city          VARCHAR(100),
    state         VARCHAR(100),
    pincode       VARCHAR(10),
    is_active     TINYINT(1)          DEFAULT 1,
    created_at    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2: categories
-- Product categories (e.g. Panjeeri, Dry Fruits, Dates)
-- ============================================================
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)        NOT NULL,
    description   TEXT,
    is_active     TINYINT(1)          DEFAULT 1,
    created_at    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 3: products
-- All Panjeeri Ghar products with FEFO expiry tracking
-- ============================================================
CREATE TABLE products (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_id   INT                 NOT NULL,
    name          VARCHAR(200)        NOT NULL,
    slug          VARCHAR(200)        NOT NULL UNIQUE,  -- URL-friendly name
    description   TEXT,
    weight_grams  INT                 NOT NULL,         -- e.g. 300, 500
    price         DECIMAL(10,2)       NOT NULL,
    mrp           DECIMAL(10,2)       NOT NULL,         -- original price before discount
    stock_qty     INT                 DEFAULT 0,
    expiry_date   DATE                NOT NULL,         -- FEFO: sort by this ASC when selling
    batch_number  VARCHAR(50),                          -- for tracking fresh batches
    image_url     VARCHAR(500),
    ingredients   TEXT,
    is_active     TINYINT(1)          DEFAULT 1,
    created_at    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Index for FEFO: always fetch soonest-expiring stock first
CREATE INDEX idx_products_expiry ON products(expiry_date ASC);

-- ============================================================
-- TABLE 4: cart
-- Session-based cart items (one row per product per user)
-- ============================================================
CREATE TABLE cart (
    cart_id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT                 NOT NULL,
    product_id    INT                 NOT NULL,
    quantity      INT                 DEFAULT 1,
    added_at      TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(user_id)    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, product_id)    -- prevent duplicate rows
);

-- ============================================================
-- TABLE 5: orders
-- One row per order placed by a customer
-- ============================================================
CREATE TABLE orders (
    order_id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id            INT                  NOT NULL,
    total_amount       DECIMAL(10,2)        NOT NULL,
    shipping_amount    DECIMAL(10,2)        DEFAULT 0.00,
    discount_amount    DECIMAL(10,2)        DEFAULT 0.00,
    final_amount       DECIMAL(10,2)        NOT NULL,   -- total_amount - discount + shipping
    shipping_address   TEXT                 NOT NULL,
    shipping_city      VARCHAR(100)         NOT NULL,
    shipping_state     VARCHAR(100)         NOT NULL,
    shipping_pincode   VARCHAR(10)          NOT NULL,
    order_status       ENUM(
                         'pending',
                         'confirmed',
                         'processing',
                         'shipped',
                         'delivered',
                         'cancelled'
                       )                   DEFAULT 'pending',
    payment_status     ENUM(
                         'unpaid',
                         'paid',
                         'failed',
                         'refunded'
                       )                   DEFAULT 'unpaid',
    notes              TEXT,
    created_at         TIMESTAMP            DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP            DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- TABLE 6: order_items
-- Individual products inside each order
-- ============================================================
CREATE TABLE order_items (
    item_id       INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT                 NOT NULL,
    product_id    INT                 NOT NULL,
    product_name  VARCHAR(200)        NOT NULL,  -- snapshot at time of purchase
    product_price DECIMAL(10,2)       NOT NULL,  -- price at time of purchase
    quantity      INT                 NOT NULL,
    subtotal      DECIMAL(10,2)       NOT NULL,  -- product_price * quantity
    FOREIGN KEY (order_id)   REFERENCES orders(order_id)   ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- TABLE 7: payments
-- Razorpay payment records — one row per payment attempt
-- ============================================================
CREATE TABLE payments (
    payment_id            INT AUTO_INCREMENT PRIMARY KEY,
    order_id              INT                  NOT NULL,
    user_id               INT                  NOT NULL,

    -- Razorpay IDs (all three needed for signature verification)
    razorpay_order_id     VARCHAR(100)         NOT NULL,   -- created by your Java backend
    razorpay_payment_id   VARCHAR(100),                    -- returned after customer pays
    razorpay_signature    VARCHAR(300),                    -- HMAC-SHA256 signature to verify

    amount                DECIMAL(10,2)        NOT NULL,   -- in INR (not paise)
    currency              VARCHAR(10)          DEFAULT 'INR',
    payment_method        VARCHAR(50),                     -- upi, card, netbanking, wallet
    payment_status        ENUM(
                            'created',    -- order created at Razorpay, not yet paid
                            'paid',       -- signature verified, money received
                            'failed',     -- payment failed at gateway
                            'refunded'    -- refund issued
                          )              DEFAULT 'created',
    failure_reason        TEXT,                            -- store error message if failed
    paid_at               TIMESTAMP,                       -- when payment was confirmed
    created_at            TIMESTAMP            DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id)  REFERENCES users(user_id)
);

-- ============================================================
-- SEED DATA — Based on live panjeerighar.com products
-- ============================================================

-- Categories
INSERT INTO categories (name, description) VALUES
('Panjeeri',    'Grain-free dry fruit panjeeri blends made with pure desi ghee'),
('Dry Fruits',  'Premium quality dates and dry fruit products');

-- Products (actual products from your Shopify site)
INSERT INTO products
  (category_id, name, slug, description, weight_grams, price, mrp, stock_qty, expiry_date, batch_number, ingredients)
VALUES
(
  1,
  'Desi Panjeeri – Traditional Jaggery Blend',
  'desi-panjeeri-traditional-jaggery-blend-300g',
  'A traditional blend sweetened with Jaggery (Gur) for authentic taste and wholesome energy. Made with 100% pure desi ghee. No wheat flour, no semolina, no fillers.',
  300, 699.00, 799.00, 50,
  DATE_ADD(CURDATE(), INTERVAL 45 DAY),
  'BATCH-DP-001',
  'Dry fruits, Jaggery (Gur), Pure Desi Ghee, Nuts, Seeds'
),
(
  1,
  'Gold Panjeeri – Premium Strength Blend',
  'gold-panjeeri-premium-strength-blend-300g',
  'Our premium strength blend, fortified with extra dry fruits and herbs for maximum vitality. Ideal for post-workout recovery and daily energy.',
  300, 699.00, 899.00, 35,
  DATE_ADD(CURDATE(), INTERVAL 45 DAY),
  'BATCH-GP-001',
  'Premium dry fruits, Herbs, Pure Desi Ghee, Nuts, Seeds, Jaggery'
),
(
  1,
  'Pure Panjeeri – Traditional Nutrition Blend',
  'pure-panjeeri-traditional-nutrition-blend-300g',
  'A classic nutrition blend focusing on essential daily wellness. Made fresh to order with zero preservatives.',
  300, 699.00, 799.00, 40,
  DATE_ADD(CURDATE(), INTERVAL 45 DAY),
  'BATCH-PP-001',
  'Dry fruits, Pure Desi Ghee, Nuts, Seeds, Natural sweetener'
),
(
  2,
  'Premium Ajwa Al-Madina Dates – The Crown of Dates',
  'premium-ajwa-al-madina-dates-500g',
  'Authentic Ajwa Al-Madina dates, sourced directly. Known as the crown of dates for their rich taste, soft texture, and health benefits.',
  500, 799.00, 999.00, 25,
  DATE_ADD(CURDATE(), INTERVAL 180 DAY),
  'BATCH-AD-001',
  'Premium Ajwa Dates (100% natural, no additives)'
);

-- Admin user (password: Admin@123 — CHANGE THIS before going live)
-- BCrypt hash of 'Admin@123':
INSERT INTO users (full_name, email, phone, password_hash, role, city, state)
VALUES (
  'Shaikh Saifullah',
  'admin@panjeerighar.com',
  '9000000000',
  '$2a$12$examplehashchangethisbeforegoingliveplease123456789',
  'admin',
  'Hyderabad',
  'Telangana'
);

-- ============================================================
-- FEFO QUERY — Use this every time you reduce stock
-- Always sell the batch expiring soonest first
-- ============================================================
-- SELECT * FROM products
-- WHERE product_id = ?
-- ORDER BY expiry_date ASC
-- LIMIT 1;

-- ============================================================
-- USEFUL QUERIES for your project report
-- ============================================================

-- Get all orders with payment status (admin dashboard):
-- SELECT o.order_id, u.full_name, u.email, o.final_amount,
--        o.order_status, o.payment_status, o.created_at
-- FROM orders o
-- JOIN users u ON o.user_id = u.user_id
-- ORDER BY o.created_at DESC;

-- Get cart items with product details for a user:
-- SELECT c.quantity, p.name, p.price, p.image_url,
--        (c.quantity * p.price) AS subtotal
-- FROM cart c
-- JOIN products p ON c.product_id = p.product_id
-- WHERE c.user_id = ?;

-- Get products expiring within 7 days (admin alert):
-- SELECT name, stock_qty, expiry_date, batch_number
-- FROM products
-- WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
-- AND is_active = 1;

