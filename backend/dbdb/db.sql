-- =====================================================
-- MULTI-VENDOR ECOMMERCE DATABASE
-- =====================================================

CREATE DATABASE IF NOT EXISTS ecommerce_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_db;

-- =====================================================
-- ROLES
-- =====================================================

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (role_name, description) VALUES
('Super Admin','System Owner'),
('Admin','System Administrator'),
('Staff','System Staff'),
('Seller','Marketplace Seller'),
('Buyer','Marketplace Buyer');

-- =====================================================
-- USERS
-- =====================================================

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    username VARCHAR(100) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(30),
    password VARCHAR(255) NOT NULL,
    profile_photo VARCHAR(255),
    status ENUM('active','inactive','suspended') DEFAULT 'active',
    email_verified_at DATETIME NULL,
    last_login DATETIME NULL,
    remember_token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- =====================================================
-- PERMISSIONS
-- =====================================================

CREATE TABLE permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,

    PRIMARY KEY(role_id, permission_id),

    FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- =====================================================
-- SELLER PROFILES
-- =====================================================

CREATE TABLE seller_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    store_name VARCHAR(255) NOT NULL,
    business_name VARCHAR(255),
    business_email VARCHAR(255),
    business_phone VARCHAR(30),
    tax_number VARCHAR(100),
    logo VARCHAR(255),
    banner VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id) REFERENCES users(id)
);

-- =====================================================
-- CATEGORIES
-- =====================================================

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    image VARCHAR(255),
    description TEXT,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(parent_id) REFERENCES categories(id)
);

-- =====================================================
-- BRANDS
-- =====================================================

CREATE TABLE brands (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    logo VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PRODUCTS
-- =====================================================

CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    category_id BIGINT,
    brand_id BIGINT,

    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    sku VARCHAR(100) UNIQUE,

    short_description TEXT,
    description LONGTEXT,

    price DECIMAL(12,2) NOT NULL,
    sale_price DECIMAL(12,2),

    stock_quantity INT DEFAULT 0,
    weight DECIMAL(10,2),

    featured BOOLEAN DEFAULT FALSE,

    status ENUM(
        'draft',
        'active',
        'inactive'
    ) DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY(seller_id) REFERENCES users(id),
    FOREIGN KEY(category_id) REFERENCES categories(id),
    FOREIGN KEY(brand_id) REFERENCES brands(id)
);

-- =====================================================
-- PRODUCT IMAGES
-- =====================================================

CREATE TABLE product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,

    FOREIGN KEY(product_id) REFERENCES products(id)
    ON DELETE CASCADE
);

-- =====================================================
-- PRODUCT VARIANTS
-- =====================================================

CREATE TABLE product_variants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_name VARCHAR(100),
    variant_value VARCHAR(100),
    additional_price DECIMAL(12,2) DEFAULT 0,
    stock_quantity INT DEFAULT 0,

    FOREIGN KEY(product_id)
    REFERENCES products(id)
    ON DELETE CASCADE
);

-- =====================================================
-- ADDRESSES
-- =====================================================

CREATE TABLE addresses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,

    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),

    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(30),

    is_default BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- =====================================================
-- CARTS
-- =====================================================

CREATE TABLE carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(buyer_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- =====================================================
-- CART ITEMS
-- =====================================================

CREATE TABLE cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,

    quantity INT NOT NULL DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(cart_id)
    REFERENCES carts(id)
    ON DELETE CASCADE,

    FOREIGN KEY(product_id)
    REFERENCES products(id)
);

-- =====================================================
-- WISHLIST
-- =====================================================

CREATE TABLE wishlists (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(buyer_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

    FOREIGN KEY(product_id)
    REFERENCES products(id)
    ON DELETE CASCADE
);

-- =====================================================
-- COUPONS
-- =====================================================

CREATE TABLE coupons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    code VARCHAR(100) UNIQUE NOT NULL,

    discount_type ENUM(
        'fixed',
        'percentage'
    ) NOT NULL,

    discount_value DECIMAL(10,2) NOT NULL,

    start_date DATE,
    end_date DATE,

    usage_limit INT DEFAULT 0,
    used_count INT DEFAULT 0,

    status TINYINT DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ORDERS
-- =====================================================

CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT NOT NULL,

    order_number VARCHAR(100) UNIQUE NOT NULL,

    subtotal DECIMAL(12,2) DEFAULT 0,
    tax DECIMAL(12,2) DEFAULT 0,
    shipping_fee DECIMAL(12,2) DEFAULT 0,
    discount DECIMAL(12,2) DEFAULT 0,

    total_amount DECIMAL(12,2) DEFAULT 0,

    payment_status ENUM(
        'pending',
        'paid',
        'failed',
        'refunded'
    ) DEFAULT 'pending',

    order_status ENUM(
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled'
    ) DEFAULT 'pending',

    notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(buyer_id)
    REFERENCES users(id)
);

-- =====================================================
-- ORDER ITEMS
-- =====================================================

CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT NOT NULL,
    seller_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,

    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,

    FOREIGN KEY(order_id)
    REFERENCES orders(id)
    ON DELETE CASCADE,

    FOREIGN KEY(seller_id)
    REFERENCES users(id),

    FOREIGN KEY(product_id)
    REFERENCES products(id)
);

-- =====================================================
-- PAYMENT METHODS
-- =====================================================

CREATE TABLE payment_methods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    method_name VARCHAR(100) NOT NULL,
    status TINYINT DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PAYMENTS
-- =====================================================

CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT NOT NULL,
    payment_method_id BIGINT NOT NULL,

    transaction_id VARCHAR(255),

    amount DECIMAL(12,2) NOT NULL,

    status ENUM(
        'pending',
        'completed',
        'failed'
    ) DEFAULT 'pending',

    paid_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(order_id)
    REFERENCES orders(id),

    FOREIGN KEY(payment_method_id)
    REFERENCES payment_methods(id)
);

-- =====================================================
-- SHIPMENTS
-- =====================================================

CREATE TABLE shipments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT NOT NULL,

    courier_name VARCHAR(255),
    tracking_number VARCHAR(255),

    shipment_status ENUM(
        'pending',
        'shipped',
        'in_transit',
        'delivered'
    ) DEFAULT 'pending',

    shipped_at DATETIME NULL,
    delivered_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(order_id)
    REFERENCES orders(id)
);

-- =====================================================
-- REVIEWS
-- =====================================================

CREATE TABLE product_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    product_id BIGINT NOT NULL,
    buyer_id BIGINT NOT NULL,

    rating TINYINT NOT NULL,
    review TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(product_id)
    REFERENCES products(id)
    ON DELETE CASCADE,

    FOREIGN KEY(buyer_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- =====================================================
-- NOTIFICATIONS
-- =====================================================

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    title VARCHAR(255),
    message TEXT,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- =====================================================
-- AUDIT LOGS
-- =====================================================

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT,

    action VARCHAR(255),
    table_name VARCHAR(100),
    record_id BIGINT,

    old_values JSON,
    new_values JSON,

    ip_address VARCHAR(45),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
    REFERENCES users(id)
);

-- =====================================================
-- SYSTEM SETTINGS
-- =====================================================

CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,

    setting_key VARCHAR(255) UNIQUE,
    setting_value LONGTEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- DEFAULT SUPER ADMIN
-- Password: admin123 (replace with bcrypt hash)
-- =====================================================

INSERT INTO users (
    role_id,
    first_name,
    last_name,
    username,
    email,
    password
)
VALUES (
    1,
    'Super',
    'Admin',
    'superadmin',
    'admin@example.com',
    '$2y$10$ReplaceWithBcryptHash'
);