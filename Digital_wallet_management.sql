-- Digital Wallet Management System Database
-- CREDX Application
-- Created: December 2025

CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    account_number VARCHAR(50) UNIQUE NOT NULL,
    account_created DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_account_number (account_number)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    account_type ENUM('SAVINGS', 'CHECKING', 'WALLET') DEFAULT 'WALLET',
    current_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    total_in DECIMAL(15, 2) DEFAULT 0.00,
    total_out DECIMAL(15, 2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'UGX',
    account_status ENUM('ACTIVE', 'SUSPENDED', 'CLOSED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_account_status (account_status)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    user_id INT NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'REFUND') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    previous_balance DECIMAL(15, 2),
    new_balance DECIMAL(15, 2),
    note VARCHAR(255),
    reference_number VARCHAR(100) UNIQUE,
    transaction_status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    payment_method VARCHAR(100),
    transaction_date DATETIME NOT NULL,
    completed_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_account_id (account_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_transaction_status (transaction_status),
    INDEX idx_transaction_date (transaction_date)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS deposits (
    deposit_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL UNIQUE,
    account_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    deposit_method VARCHAR(100) NOT NULL,
    bank_name VARCHAR(100),
    bank_account VARCHAR(50),
    deposit_date DATETIME NOT NULL,
    confirmation_number VARCHAR(100),
    deposit_status ENUM('PENDING', 'CONFIRMED', 'FAILED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_deposit_status (deposit_status)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS withdrawals (
    withdrawal_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL UNIQUE,
    account_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    withdrawal_method VARCHAR(100) NOT NULL,
    bank_name VARCHAR(100),
    bank_account VARCHAR(50),
    withdrawal_date DATETIME NOT NULL,
    processed_date DATETIME,
    withdrawal_status ENUM('PENDING', 'PROCESSED', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_withdrawal_status (withdrawal_status)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS transfers (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL UNIQUE,
    from_account_id INT NOT NULL,
    to_account_id INT,
    from_user_id INT NOT NULL,
    to_user_id INT,
    amount DECIMAL(15, 2) NOT NULL,
    transfer_date DATETIME NOT NULL,
    transfer_status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    transfer_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (from_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_from_user (from_user_id),
    INDEX idx_to_user (to_user_id)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS kyc_information (
    kyc_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    id_type ENUM('NATIONAL_ID', 'PASSPORT', 'DRIVERS_LICENSE', 'OTHER') NOT NULL,
    id_number VARCHAR(100) NOT NULL,
    id_expiry_date DATE,
    date_of_birth DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    verification_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    verified_date DATETIME,
    verified_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_verification_status (verification_status)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    related_transaction_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(100),
    entity_id INT,
    old_value TEXT,
    new_value TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_entity (entity_type, entity_id)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS security_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_method ENUM('SMS', 'EMAIL', 'APP') DEFAULT 'SMS',
    backup_codes TEXT,
    last_password_change DATETIME,
    failed_login_attempts INT DEFAULT 0,
    locked_until DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS payment_methods (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    method_type ENUM('BANK_ACCOUNT', 'CARD', 'MOBILE_MONEY', 'WALLET') NOT NULL,
    account_name VARCHAR(255),
    account_number VARCHAR(50),
    bank_code VARCHAR(10),
    bank_name VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_method_type (method_type)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS promotional_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    image_url VARCHAR(500),
    image_path VARCHAR(500),
    alt_text VARCHAR(255),
    display_order INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB;


-- ============================================
-- VIEWS
-- ============================================

-- View: Account Summary
CREATE OR REPLACE VIEW account_summary AS
SELECT 
    u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    u.account_number,
    a.account_id,
    a.current_balance,
    a.total_in,
    a.total_out,
    a.account_status,
    COUNT(t.transaction_id) as total_transactions,
    MAX(t.transaction_date) as last_transaction_date
FROM users u
JOIN accounts a ON u.user_id = a.user_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY u.user_id, a.account_id;

-- View: Recent Transactions
CREATE OR REPLACE VIEW recent_transactions AS
SELECT 
    t.transaction_id,
    t.user_id,
    u.email,
    u.first_name,
    u.last_name,
    t.transaction_type,
    t.amount,
    t.transaction_status,
    t.transaction_date,
    t.note
FROM transactions t
JOIN users u ON t.user_id = u.user_id
ORDER BY t.transaction_date DESC
LIMIT 100;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure: Create New User Account
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_create_user_account(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    OUT p_user_id INT,
    OUT p_account_number VARCHAR(50)
)
-- Example 1: Create User Account
CALL sp_create_user_account(
    'john.doe@example.com',           -- p_email
    '$2y$10$hashedpassword123',       -- p_password
    'John',                            -- p_first_name
    'Doe',                             -- p_last_name
    '0700555123',                      -- p_phone
    @user_id,                          -- OUT p_user_id
    @account_number                    -- OUT p_account_number
);
SELECT @user_id, @account_number;


-- Example 2: Process Deposit
CALL sp_process_deposit(
    1,                                 -- p_account_id
    1,                                 -- p_user_id
    3500.00,                           -- p_amount
    'BANK_TRANSFER',                   -- p_deposit_method
    'Stanbic Bank',                    -- p_bank_name
    @transaction_id,                   -- OUT p_transaction_id
    @new_balance                       -- OUT p_new_balance
);
SELECT @transaction_id, @new_balance;


-- Example 3: Process Withdrawal
CALL sp_process_withdrawal(
    1,                                 -- p_account_id
    1,                                 -- p_user_id
    2000.00,                           -- p_amount
    'ATM',                             -- p_withdrawal_method
    'Stanbic Bank',                    -- p_bank_name
    @transaction_id,                   -- OUT p_transaction_id
    @new_balance,                      -- OUT p_new_balance
    @success                           -- OUT p_success
);
SELECT @transaction_id, @new_balance, @success;


-- Example 4: Get Dashboard Summary
CALL sp_get_dashboard_summary(1);     -- p_user_id
BEGIN
    DECLARE v_account_number VARCHAR(50);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error creating user' AS message;
    END;
    
    START TRANSACTION;
    
    -- Generate unique account number
    SET v_account_number = CONCAT('CREDX', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 10000), 4, '0'));
    
    -- Insert user
    INSERT INTO users (email, password, first_name, last_name, phone_number, account_number, account_created)
    VALUES (p_email, p_password, p_first_name, p_last_name, p_phone, v_account_number, CURDATE());
    
    SET p_user_id = LAST_INSERT_ID();
    SET p_account_number = v_account_number;
    
    -- Create wallet account
    INSERT INTO accounts (user_id, account_type, current_balance, account_created)
    VALUES (p_user_id, 'WALLET', 0.00);
    
    -- Create security settings
    INSERT INTO security_settings (user_id)
    VALUES (p_user_id);
    
    COMMIT;
END$$
DELIMITER ;

-- Procedure: Process Deposit
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_process_deposit(
    IN p_account_id INT,
    IN p_user_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_deposit_method VARCHAR(100),
    IN p_bank_name VARCHAR(100),
    OUT p_transaction_id INT,
    OUT p_new_balance DECIMAL(15,2)
)
BEGIN
    DECLARE v_previous_balance DECIMAL(15,2);
    DECLARE v_reference_number VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error processing deposit' AS message;
    END;
    
    START TRANSACTION;
    
    -- Get current balance
    SELECT current_balance INTO v_previous_balance FROM accounts WHERE account_id = p_account_id;
    
    -- Generate reference number
    SET v_reference_number = CONCAT('DEP', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), LPAD(p_account_id, 5, '0'));
    
    -- Insert transaction
    INSERT INTO transactions (account_id, user_id, transaction_type, amount, previous_balance, 
                             new_balance, reference_number, transaction_status, payment_method, transaction_date)
    VALUES (p_account_id, p_user_id, 'DEPOSIT', p_amount, v_previous_balance, 
            v_previous_balance + p_amount, v_reference_number, 'COMPLETED', p_deposit_method, NOW());
    
    SET p_transaction_id = LAST_INSERT_ID();
    SET p_new_balance = v_previous_balance + p_amount;
    
    -- Insert deposit record
    INSERT INTO deposits (transaction_id, account_id, user_id, amount, deposit_method, 
                         bank_name, deposit_date, deposit_status)
    VALUES (p_transaction_id, p_account_id, p_user_id, p_amount, p_deposit_method, 
            p_bank_name, NOW(), 'CONFIRMED');
    
    -- Update account balance
    UPDATE accounts SET current_balance = p_new_balance, total_in = total_in + p_amount 
    WHERE account_id = p_account_id;
    
    -- Create notification
    INSERT INTO notifications (user_id, notification_type, title, message, related_transaction_id)
    VALUES (p_user_id, 'DEPOSIT', 'Deposit Successful', 
            CONCAT('Your deposit of ', p_amount, ' UGX has been credited to your account'), p_transaction_id);
    
    COMMIT;
END$$
DELIMITER ;

-- Procedure: Process Withdrawal
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_process_withdrawal(
    IN p_account_id INT,
    IN p_user_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_withdrawal_method VARCHAR(100),
    IN p_bank_name VARCHAR(100),
    OUT p_transaction_id INT,
    OUT p_new_balance DECIMAL(15,2),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_current_balance DECIMAL(15,2);
    DECLARE v_reference_number VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
    END;
    
    START TRANSACTION;
    
    -- Get current balance
    SELECT current_balance INTO v_current_balance FROM accounts WHERE account_id = p_account_id;
    
    -- Check if sufficient balance
    IF v_current_balance < p_amount THEN
        SET p_success = FALSE;
        ROLLBACK;
    ELSE
        -- Generate reference number
        SET v_reference_number = CONCAT('WIT', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), LPAD(p_account_id, 5, '0'));
        
        -- Insert transaction
        INSERT INTO transactions (account_id, user_id, transaction_type, amount, previous_balance, 
                                 new_balance, reference_number, transaction_status, payment_method, transaction_date)
        VALUES (p_account_id, p_user_id, 'WITHDRAWAL', p_amount, v_current_balance, 
                v_current_balance - p_amount, v_reference_number, 'COMPLETED', p_withdrawal_method, NOW());
        
        SET p_transaction_id = LAST_INSERT_ID();
        SET p_new_balance = v_current_balance - p_amount;
        SET p_success = TRUE;
        
        -- Insert withdrawal record
        INSERT INTO withdrawals (transaction_id, account_id, user_id, amount, withdrawal_method, 
                               bank_name, withdrawal_date, processed_date, withdrawal_status)
        VALUES (p_transaction_id, p_account_id, p_user_id, p_amount, p_withdrawal_method, 
                p_bank_name, NOW(), NOW(), 'COMPLETED');
        
        -- Update account balance
        UPDATE accounts SET current_balance = p_new_balance, total_out = total_out + p_amount 
        WHERE account_id = p_account_id;
        
        -- Create notification
        INSERT INTO notifications (user_id, notification_type, title, message, related_transaction_id)
        VALUES (p_user_id, 'WITHDRAWAL', 'Withdrawal Processed', 
                CONCAT('Your withdrawal of ', p_amount, ' UGX has been processed'), p_transaction_id);
        
        COMMIT;
    END IF;
END$$
DELIMITER ;

-- Procedure: Get User Dashboard Summary
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_get_dashboard_summary(
    IN p_user_id INT
)
BEGIN
    SELECT 
        u.user_id,
        u.email,
        CONCAT(u.first_name, ' ', u.last_name) as full_name,
        u.account_number,
        u.account_created,
        a.account_id,
        a.current_balance,
        a.total_in,
        a.total_out,
        a.account_status,
        (SELECT COUNT(*) FROM transactions WHERE user_id = p_user_id) as total_transactions
    FROM users u
    JOIN accounts a ON u.user_id = a.user_id
    WHERE u.user_id = p_user_id;
    
    -- Get recent transactions
    SELECT 
        transaction_id,
        transaction_type,
        amount,
        transaction_status,
        transaction_date,
        note
    FROM transactions
    WHERE user_id = p_user_id
    ORDER BY transaction_date DESC
    LIMIT 10;
END$$
DELIMITER ;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON transactions(user_id, transaction_date DESC);

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample promotional images
INSERT INTO promotional_images (title, image_url, alt_text, display_order, is_active) VALUES
('Shopping Experience', '/images/promotional/shopping.jpg', 'Woman shopping', 1, TRUE),
('Secure Transactions', '/images/promotional/secure.jpg', 'Secure shopping', 2, TRUE),
('Easy Payments', '/images/promotional/payments.jpg', 'Easy payment methods', 3, TRUE),
('Fast Delivery', '/images/promotional/delivery.jpg', 'Fast delivery service', 4, TRUE),
('Premium Quality', '/images/promotional/quality.jpg', 'Premium products', 5, TRUE),
('Customer Support', '/images/promotional/support.jpg', 'Customer support team', 6, TRUE);


-- ============================================
-- SAMPLE DATA: USERS, ACCOUNTS, TRANSACTIONS, ETC.
-- ============================================

-- Users
INSERT INTO users (email, password, first_name, last_name, phone_number, account_number, account_created, is_active, is_verified)
VALUES
('keith@example.com', '$2y$10$examplehash1', 'Keith', 'Muriuki', '0700123456', 'CREDX202512090001', '2024-09-12', TRUE, TRUE),
('alice@example.com', '$2y$10$examplehash2', 'Alice', 'Okello', '0700654321', 'CREDX202512090002', '2024-10-01', TRUE, TRUE),
('bob@example.com', '$2y$10$examplehash3', 'Bob', 'Namara', '0700987654', 'CREDX202512090003', '2024-11-05', TRUE, FALSE);

-- Accounts (link to users above)
INSERT INTO accounts (user_id, account_type, current_balance, total_in, total_out, currency, account_status)
VALUES
(1, 'WALLET', 12500.00, 7000.00, 1500.00, 'UGX', 'ACTIVE'),
(2, 'WALLET', 5000.00, 5000.00, 0.00, 'UGX', 'ACTIVE'),
(3, 'WALLET', 0.00, 0.00, 0.00, 'UGX', 'ACTIVE');

-- Security settings
INSERT INTO security_settings (user_id, two_factor_enabled, two_factor_method, last_password_change, failed_login_attempts)
VALUES
(1, TRUE, 'SMS', '2025-11-01', 0),
(2, FALSE, 'EMAIL', '2025-10-15', 1),
(3, FALSE, 'SMS', NULL, 0);

-- Payment methods
INSERT INTO payment_methods (user_id, method_type, account_name, account_number, bank_name, is_default, is_verified)
VALUES
(1, 'BANK_ACCOUNT', 'Keith Muriuki', '9012345678', 'Stanbic Bank', TRUE, TRUE),
(2, 'MOBILE_MONEY', 'Alice Okello', '0789123456', 'MTN Mobile Money', TRUE, TRUE);

-- KYC information
INSERT INTO kyc_information (user_id, id_type, id_number, id_expiry_date, date_of_birth, address, city, country, verification_status)
VALUES
(1, 'NATIONAL_ID', 'NIN001234567', '2030-12-31', '1990-05-20', 'Plot 12, Kampala Rd', 'Kampala', 'Uganda', 'APPROVED'),
(2, 'PASSPORT', 'P987654321', '2029-06-01', '1992-08-15', 'Plot 45, Jinja Rd', 'Kampala', 'Uganda', 'APPROVED');

-- Transactions + Deposits + Withdrawals sample
-- Deposit: 2000 UGX to Keith (user_id 1, account_id 1)
INSERT INTO transactions (account_id, user_id, transaction_type, amount, previous_balance, new_balance, reference_number, transaction_status, payment_method, transaction_date)
VALUES
(1, 1, 'WITHDRAWAL', 300.00, 12800.00, 12500.00, 'WIT20251204083200', 'COMPLETED', 'ATM', '2025-12-04 08:32:00'),
(1, 1, 'DEPOSIT', 2000.00, 10500.00, 12500.00, 'DEP20251202112000', 'COMPLETED', 'BANK_TRANSFER', '2025-12-02 11:20:00'),
(1, 1, 'WITHDRAWAL', 1200.00, 13700.00, 12500.00, 'WIT20251201140500', 'COMPLETED', 'ATM', '2025-12-01 14:05:00'),
(1, 1, 'DEPOSIT', 5000.00, 8000.00, 13000.00, 'DEP20251130091200', 'COMPLETED', 'BANK_TRANSFER', '2025-11-30 09:12:00');

-- Note: adjust previous_balance/new_balance in sample rows to reflect desired history for testing.

-- Link deposits/withdrawals to transactions
INSERT INTO deposits (transaction_id, account_id, user_id, amount, deposit_method, bank_name, deposit_date, deposit_status)
VALUES
(2, 1, 1, 2000.00, 'BANK_TRANSFER', 'Stanbic Bank', '2025-12-02 11:20:00', 'CONFIRMED'),
(4, 1, 1, 5000.00, 'BANK_TRANSFER', 'Stanbic Bank', '2025-11-30 09:12:00', 'CONFIRMED');

INSERT INTO withdrawals (transaction_id, account_id, user_id, amount, withdrawal_method, bank_name, withdrawal_date, processed_date, withdrawal_status)
VALUES
(1, 1, 1, 300.00, 'ATM', 'Stanbic Bank', '2025-12-04 08:32:00', '2025-12-04 08:45:00', 'COMPLETED'),
(3, 1, 1, 1200.00, 'ATM', 'Stanbic Bank', '2025-12-01 14:05:00', '2025-12-01 14:20:00', 'COMPLETED');

-- Transfers sample (user 1 sends 500 UGX to user 2)
INSERT INTO transactions (account_id, user_id, transaction_type, amount, previous_balance, new_balance, reference_number, transaction_status, payment_method, transaction_date)
VALUES
(1, 1, 'TRANSFER', 500.00, 12500.00, 12000.00, 'TRF20251205100000', 'COMPLETED', 'WALLET', '2025-12-05 10:00:00');

INSERT INTO transfers (transaction_id, from_account_id, to_account_id, from_user_id, to_user_id, amount, transfer_date, transfer_status, transfer_description)
VALUES
(LAST_INSERT_ID(), 1, 2, 1, 2, 500.00, '2025-12-05 10:00:00', 'COMPLETED', 'Payment for groceries');

-- Notifications
INSERT INTO notifications (user_id, notification_type, title, message, related_transaction_id, is_read)
VALUES
(1, 'DEPOSIT', 'Deposit Successful', 'Your deposit of 2,000 UGX has been credited to your account', 2, FALSE),
(1, 'WITHDRAWAL', 'Withdrawal Processed', 'Your withdrawal of 300 UGX has been processed', 1, TRUE),
(2, 'TRANSFER', 'You received a transfer', 'You received 500 UGX from keith@example.com', LAST_INSERT_ID(), FALSE);

-- Audit logs
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_value, new_value, ip_address, user_agent)
VALUES
(1, 'USER_LOGIN', 'user', 1, NULL, NULL, '127.0.0.1', 'Mozilla/5.0'),
(1, 'DEPOSIT', 'transaction', 2, '10500', '12500', '127.0.0.1', 'Mozilla/5.0');

-- Set AUTO_INCREMENT values to avoid collisions when you insert more data
ALTER TABLE users AUTO_INCREMENT = 10;
ALTER TABLE accounts AUTO_INCREMENT = 10;
ALTER TABLE transactions AUTO_INCREMENT = 100;
ALTER TABLE deposits AUTO_INCREMENT = 100;
ALTER TABLE withdrawals AUTO_INCREMENT = 100;
ALTER TABLE transfers AUTO_INCREMENT = 100;
ALTER TABLE promotional_images AUTO_INCREMENT = 20;

