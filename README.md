# Panjeeri Ghar

A full-stack e-commerce web application for a homemade food brand — built with Java Servlet, JSP, and MySQL.

**Student:** Shaikh Saifullah | BCA 6th Semester | Osmania University

---

## Features

- Customer registration, login, and OTP-based email verification
- Google OAuth login
- Product catalog with category filtering
- Shopping cart and checkout flow
- Razorpay payment gateway integration
- Order tracking and history
- Admin dashboard — manage products, orders, and users

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java Servlets (Jakarta EE) |
| Frontend | JSP, HTML, CSS |
| Database | MySQL 8 |
| Server | Apache Tomcat 10.1 |
| Payments | Razorpay |
| Email | Gmail SMTP (Jakarta Mail) |
| Auth | BCrypt passwords + Google OAuth 2.0 |
| Build | Maven |

## Project Structure

```
src/
├── main/
│   ├── java/com/panjeerighar/
│   │   ├── filter/        # Auth filters
│   │   ├── model/         # POJOs (User, Product, CartItem)
│   │   ├── servlet/       # All request handlers
│   │   │   └── admin/     # Admin-only servlets
│   │   └── util/          # DBConnection, EmailService
│   └── webapp/
│       ├── admin/         # Admin JSP pages
│       ├── css/           # Stylesheets
│       └── *.jsp          # Customer-facing pages
└── Panjeeri Ghar Database/
    └── panjeeri_ghar_database.sql
```

## Setup

### Prerequisites

- JDK 17+
- Apache Tomcat 10.1
- MySQL 8
- Maven

### 1. Database

```sql
mysql -u root -p < "Panjeeri Ghar Database/panjeeri_ghar_database.sql"
```

### 2. Environment Variables

Copy `.env.example` and fill in your values. For Tomcat, set these in `TOMCAT_HOME/bin/setenv.bat` (Windows) or `setenv.sh` (Linux/Mac):

```bat
set "DB_PASSWORD=your_mysql_password"
set "SMTP_USER=your@gmail.com"
set "SMTP_PASS=your_gmail_app_password"
set "RAZORPAY_KEY_ID=rzp_live_..."
set "RAZORPAY_KEY_SECRET=..."
set "GOOGLE_CLIENT_ID=..."
set "GOOGLE_CLIENT_SECRET=..."
set "GOOGLE_REDIRECT_URI=http://localhost:8080/panjeeri-ghar/auth/google/callback"
```

### 3. Build & Deploy

```bash
mvn clean package
cp target/panjeeri-ghar.war TOMCAT_HOME/webapps/
```

Start Tomcat and visit: **http://localhost:8080/panjeeri-ghar**

## Environment Variables Reference

| Variable | Description |
|---|---|
| `DB_URL` | JDBC connection string (defaults to localhost) |
| `DB_USER` | MySQL username |
| `DB_PASSWORD` | MySQL password |
| `SMTP_USER` | Gmail address for sending emails |
| `SMTP_PASS` | Gmail App Password (not your account password) |
| `RAZORPAY_KEY_ID` | Razorpay API key ID |
| `RAZORPAY_KEY_SECRET` | Razorpay API key secret |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |
| `GOOGLE_REDIRECT_URI` | OAuth callback URL |
