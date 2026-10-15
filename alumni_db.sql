
CREATE DATABASE IF NOT EXISTS alumni_db;
USE alumni_db;


CREATE TABLE IF NOT EXISTS roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);


CREATE TABLE IF NOT EXISTS programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_code VARCHAR(20) NOT NULL UNIQUE,
    program_name VARCHAR(100) NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE'
);


CREATE TABLE IF NOT EXISTS alumni (
    alumni_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    program_id INT,
    batch_year INT NOT NULL,
    graduation_status VARCHAR(50),
    current_status ENUM('ACTIVE', 'INACTIVE', 'DECEASED', 'UNVERIFIED') DEFAULT 'ACTIVE',
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);


CREATE TABLE IF NOT EXISTS graduation_records (
    graduation_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT,
    program_id INT,
    graduation_date DATE,
    graduation_year INT NOT NULL,
    academic_year VARCHAR(20),
    honors VARCHAR(100),
    latin_honors VARCHAR(50),
    graduation_status VARCHAR(50),
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);


CREATE TABLE IF NOT EXISTS companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    address TEXT,
    contact_person VARCHAR(100),
    contact_number VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS employment_records (
    employment_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT,
    company_id INT,
    job_title VARCHAR(100) NOT NULL,
    employment_type ENUM('Full-Time', 'Part-Time', 'Contractual', 'Self-Employed', 'Entrepreneur', 'Freelance'),
    start_date DATE,
    end_date DATE,
    salary_range VARCHAR(50),
    employment_status ENUM('EMPLOYED', 'SELF-EMPLOYED', 'UNEMPLOYED', 'ENTREPRENEUR', 'FREELANCER', 'RETIRED'),
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);


CREATE TABLE IF NOT EXISTS events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    event_date DATE,
    start_time TIME,
    end_time TIME,
    venue VARCHAR(150),
    registration_deadline DATE,
    maximum_participants INT,
    status ENUM('DRAFT', 'PUBLISHED', 'OPEN FOR REGISTRATION', 'CLOSED', 'COMPLETED') DEFAULT 'DRAFT'
);

CREATE TABLE IF NOT EXISTS event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    alumni_id INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('CONFIRMED', 'CANCELLED') DEFAULT 'CONFIRMED',
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id)
);

CREATE TABLE IF NOT EXISTS event_attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_id INT,
    attendance_date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_in TIME,
    check_out TIME,
    status ENUM('REGISTERED', 'ATTENDED', 'ABSENT', 'CANCELLED') DEFAULT 'REGISTERED',
    FOREIGN KEY (registration_id) REFERENCES event_registrations(registration_id)
);


CREATE TABLE IF NOT EXISTS donation_campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(150) NOT NULL,
    description TEXT,
    target_amount DECIMAL(12, 2),
    start_date DATE,
    end_date DATE,
    status ENUM('ACTIVE', 'CLOSED', 'COMPLETED') DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS donations (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT,
    campaign_id INT,
    donation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    donation_type ENUM('Cash', 'Equipment', 'Books', 'Supplies', 'Services', 'Other'),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    reference_number VARCHAR(100) UNIQUE,
    status ENUM('PENDING', 'VERIFIED', 'RECEIVED', 'REJECTED') DEFAULT 'PENDING',
    verifier_id INT,
    verification_date DATETIME,
    remarks TEXT,
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id),
    FOREIGN KEY (campaign_id) REFERENCES donation_campaigns(campaign_id),
    FOREIGN KEY (verifier_id) REFERENCES users(user_id)
);


CREATE TABLE IF NOT EXISTS communication_logs (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    subject VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    target_audience VARCHAR(100),
    date_sent TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sender_id INT,
    status VARCHAR(50),
    FOREIGN KEY (sender_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    record_affected VARCHAR(100),
    date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO programs (program_id, program_code, program_name, status) VALUES 
(1, 'BSIT', 'BS Information Technology', 'Active'),
(2, 'BSCS', 'BS Computer Science', 'Active'),
(3, 'BSLIS', 'BS Library and Information Science', 'Active'),
(4, 'BS MATH', 'BS Mathematics', 'Active');


USE alumni_db;
INSERT INTO roles (role_id, role_name) VALUES (1, 'admin'), (2, 'staff');
INSERT INTO users (username, password_hash, role_id) VALUES 
('admin_user', 'admin123', 1),
('staff_user', 'staff123', 2);

USE alumni_db;
ALTER TABLE users RENAME COLUMN password_hash TO password;
ALTER TABLE alumni ADD COLUMN is_deleted TINYINT(1) DEFAULT 0;
ALTER TABLE alumni MODIFY COLUMN current_status VARCHAR(20) DEFAULT 'Active';

USE alumni_db;
UPDATE roles 
SET role_name = 'alumni_user' 
WHERE role_name = 'staff_user';

UPDATE roles 
SET role_name = 'alumni' 
WHERE role_name = 'alumni_user';

UPDATE users 
SET password = 'alumni123' 
WHERE password = 'staff123';

INSERT INTO roles (role_id, role_name) VALUES 
(3, 'employment'),
(4, 'events'),
(5, 'fundraising'),
(6, 'communication'),
(7, 'report');

INSERT INTO users (username, password, role_id) VALUES 
('employment_user', 'employment123', 3),
('events_user', 'event123', 4),
('fundraising_user', 'fundraising123', 5),
('communication_user', 'communication123', 6),
('report_user', 'report123', 7);


SELECT * FROM alumni;

