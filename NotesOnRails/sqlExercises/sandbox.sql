-- =============================================================================
-- I. PREPARE FOR TABLE RECREATION (MySQL specific)
-- =============================================================================
SET FOREIGN_KEY_CHECKS = 0; -- Disable foreign key checks for clean dropping

-- =============================================================================
-- II. DROP TABLES (in reverse order of dependencies)
-- =============================================================================
DROP TABLE IF EXISTS EventRegistrations;
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Lessons;
DROP TABLE IF EXISTS Modules;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Categories;

-- =============================================================================
-- III. CREATE TABLES (MySQL Syntax)
-- =============================================================================

-- 1. Categories Table
CREATE TABLE Categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users Table
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. Instructors Table
CREATE TABLE Instructors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    bio TEXT,
    expertise_area VARCHAR(255),
    website_url VARCHAR(255),
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 4. Courses Table
CREATE TABLE Courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructor_id INT NOT NULL,
    category_id INT,
    price DECIMAL(10, 2) NOT NULL,
    published_at TIMESTAMP NULL,
    status VARCHAR(50) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE SET NULL,
    CONSTRAINT chk_course_price CHECK (price >= 0),
    CONSTRAINT chk_course_status CHECK (status IN ('draft', 'published', 'archived'))
);

-- 5. Modules Table
CREATE TABLE Modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    order_in_course INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, order_in_course),
    FOREIGN KEY (course_id) REFERENCES Courses(id) ON DELETE CASCADE
);

-- 6. Lessons Table
CREATE TABLE Lessons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content_type VARCHAR(50),
    content_url_or_text TEXT,
    duration_minutes INT,
    order_in_module INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (module_id, order_in_module),
    FOREIGN KEY (module_id) REFERENCES Modules(id) ON DELETE CASCADE,
    CONSTRAINT chk_lesson_content_type CHECK (content_type IN ('video', 'text', 'quiz', 'document')),
    CONSTRAINT chk_lesson_duration CHECK (duration_minutes > 0)
);

-- 7. Enrollments Table
CREATE TABLE Enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_percentage INT DEFAULT 0,
    completed_at TIMESTAMP NULL,
    UNIQUE (user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(id) ON DELETE CASCADE,
    CONSTRAINT chk_enrollment_progress CHECK (progress_percentage BETWEEN 0 AND 100)
);

-- 8. Events Table  -- *** MODIFIED HERE ***
CREATE TABLE Events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructor_id INT,
    category_id INT,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Added DEFAULT
    end_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Added DEFAULT
    location_or_url VARCHAR(255),
    price DECIMAL(10, 2) DEFAULT 0.00,
    capacity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE SET NULL,
    CONSTRAINT chk_event_price CHECK (price >= 0),
    CONSTRAINT chk_event_capacity CHECK (capacity > 0),
    CONSTRAINT chk_event_times CHECK (end_time > start_time)
);

-- 9. EventRegistrations Table
CREATE TABLE EventRegistrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'confirmed',
    UNIQUE (user_id, event_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES Events(id) ON DELETE CASCADE,
    CONSTRAINT chk_eventreg_status CHECK (status IN ('confirmed', 'cancelled', 'waitlisted'))
);

-- =============================================================================
-- IV. RE-ENABLE FOREIGN KEY CHECKS
-- =============================================================================
SET FOREIGN_KEY_CHECKS = 1; -- Re-enable foreign key checks

-- =============================================================================
-- V. INSERT SAMPLE DATA
-- =============================================================================

-- 1. Categories Table
INSERT INTO Categories (name, description) VALUES
('Web Development', 'Courses and events related to building websites and web applications.'),
('Data Science', 'Learn to analyze data, build models, and extract insights.'),
('Mobile Development', 'Developing applications for iOS and Android platforms.'),
('Business & Entrepreneurship', 'Skills for starting and growing a business.'),
('Creative Arts', 'Photography, design, music, and more.'),
('Personal Development', 'Improve your life skills and well-being.'),
('Cloud Computing', 'Learn about AWS, Azure, GCP and other cloud platforms.');

-- 2. Users Table
INSERT INTO Users (first_name, last_name, email, password_hash, registration_date, last_login, is_active) VALUES
('Alice', 'Smith', 'alice.smith@example.com', 'hash123', '2022-01-15 10:00:00', '2023-10-25 09:00:00', TRUE),
('Bob', 'Johnson', 'bob.johnson@example.com', 'hash456', '2022-02-20 11:30:00', '2023-10-20 15:00:00', TRUE),
('Carol', 'Williams', 'carol.williams@example.com', 'hash789', '2022-03-10 14:00:00', '2023-09-15 12:00:00', FALSE),
('David', 'Brown', 'david.brown@example.com', 'hashabc', '2022-04-05 16:45:00', '2023-10-26 08:30:00', TRUE),
('Eve', 'Davis', 'eve.davis@example.com', 'hashdef', '2022-05-12 09:15:00', '2023-10-01 10:00:00', TRUE),
('Frank', 'Miller', 'frank.miller@example.com', 'hashghi', '2023-01-20 12:00:00', '2023-10-24 11:00:00', TRUE),
('Grace', 'Wilson', 'grace.wilson@example.com', 'hashjkl', '2023-02-15 13:30:00', '2023-09-30 14:00:00', TRUE),
('Henry', 'Moore', 'henry.moore@example.com', 'hashmno', '2023-03-25 15:00:00', NULL, TRUE),
('Ivy', 'Taylor', 'ivy.taylor@example.com', 'hashpqr', '2023-04-10 17:15:00', '2023-10-15 16:00:00', TRUE),
('Jack', 'Anderson', 'jack.anderson@example.com', 'hashstu', '2023-05-01 08:00:00', '2023-10-26 10:30:00', TRUE),
('Karen', 'Thomas', 'karen.thomas@example.com', 'hashvwx', '2023-06-11 10:30:00', '2023-06-12 09:00:00', FALSE),
('Leo', 'Jackson', 'leo.jackson@example.com', 'hashyz0', '2023-07-15 11:00:00', '2023-10-05 18:00:00', TRUE),
('Mia', 'White', 'mia.white@example.com', 'hash123b', '2023-08-02 14:30:00', '2023-10-22 13:00:00', TRUE),
('Noah', 'Harris', 'noah.harris@example.com', 'hash456c', '2023-09-10 16:00:00', '2023-10-25 17:00:00', TRUE),
('Olivia', 'Martin', 'olivia.martin@example.com', 'hash789d', '2023-10-05 09:45:00', '2023-10-26 11:15:00', TRUE);

-- 3. Instructors Table
INSERT INTO Instructors (user_id, bio, expertise_area, website_url, joined_date) VALUES
(1, 'Alice is a full-stack developer with 10 years of experience.', 'Full-Stack Web Development', 'http://alice.dev', '2022-01-20 10:00:00'),
(2, 'Bob specializes in data science and machine learning.', 'Data Science, Python', 'http://bobdata.com', '2022-02-25 11:30:00'),
(4, 'David is an expert in mobile app development for iOS and Android.', 'Mobile Development, Swift, Kotlin', NULL, '2022-04-10 16:45:00'),
(6, 'Frank has launched multiple successful startups.', 'Entrepreneurship, Marketing', 'http://frankmiller.biz', '2023-01-25 12:00:00'),
(7, 'Grace is a passionate photographer and graphic designer.', 'Photography, Graphic Design', 'http://gracewilson.art', '2023-02-20 13:30:00'),
(9, 'Ivy Taylor is a certified AWS solutions architect.', 'Cloud Computing, AWS', 'http://ivycloud.com', '2023-04-15 00:00:00'),
(10, 'Jack Anderson focuses on mindfulness and productivity.', 'Personal Development, Productivity', 'http://jackhelps.com', '2023-05-05 00:00:00');

-- 4. Courses Table
INSERT INTO Courses (title, description, instructor_id, category_id, price, published_at, status, created_at, updated_at) VALUES
('Ultimate Web Developer Bootcamp', 'Learn HTML, CSS, JavaScript, Node.js, React, and more!', 1, 1, 199.99, '2022-03-01 00:00:00', 'published', '2022-02-15 00:00:00', '2022-02-20 00:00:00'),
('Data Science with Python A-Z', 'Master data analysis, visualization, and machine learning.', 2, 2, 149.50, '2022-04-01 00:00:00', 'published', '2022-03-10 00:00:00', '2022-03-15 00:00:00'),
('iOS App Development for Beginners', 'Build your first iPhone app with Swift and Xcode.', 3, 3, 99.00, '2022-05-15 00:00:00', 'published', '2022-05-01 00:00:00', '2022-05-05 00:00:00'),
('Startup 101: From Idea to Launch', 'A comprehensive guide to starting your own business.', 4, 4, 79.99, NULL, 'draft', '2023-02-01 00:00:00', '2023-02-01 00:00:00'),
('Digital Photography Masterclass', 'Learn to take stunning photos with any camera.', 5, 5, 120.00, '2023-03-10 00:00:00', 'published', '2023-03-01 00:00:00', '2023-03-05 00:00:00'),
('Mindfulness for a Better Life', 'Techniques to reduce stress and improve focus.', 7, 6, 0.00, '2023-06-01 00:00:00', 'published', '2023-05-20 00:00:00', '2023-05-20 00:00:00'),
('Advanced JavaScript Concepts', 'Deep dive into closures, prototypes, and async JS.', 1, 1, 89.00, '2023-07-01 00:00:00', 'published', '2023-06-15 00:00:00', '2023-06-20 00:00:00'),
('Machine Learning Foundations', 'Introduction to core ML algorithms and practices.', 2, 2, 130.00, NULL, 'archived', '2022-08-01 00:00:00', '2023-01-10 00:00:00'),
('Android Jetpack Compose Mastery', 'Modern Android UI development.', 3, 3, 110.00, '2023-09-01 00:00:00', 'published', '2023-08-15 00:00:00', '2023-08-20 00:00:00'),
('AWS Certified Cloud Practitioner', 'Prepare for the AWS CCP exam.', 6, 7, 49.99, '2023-05-01 00:00:00', 'published', '2023-04-20 00:00:00', '2023-04-25 00:00:00'),
('Python for Everybody Specialization', 'A very popular Python course for beginners.', 2, 1, 0.00, '2022-06-01 00:00:00', 'published', '2022-05-01 00:00:00', '2022-05-01 00:00:00'),
('The Complete Node.js Developer Course', 'Learn Node.js by building real-world applications.', 1, 1, 94.50, '2023-01-15 00:00:00', 'published', '2023-01-01 00:00:00', '2023-01-01 00:00:00'),
('React - The Complete Guide (incl Hooks, React Router, Redux)', 'Dive in and learn React.js from scratch!', 1, 1, 109.99, '2022-11-01 00:00:00', 'published', '2022-10-15 00:00:00', '2022-10-15 00:00:00'),
('Digital Marketing Fundamentals', 'Learn SEO, content marketing, and social media strategy.', 4, 4, 60.00, NULL, 'draft', '2023-08-01 00:00:00', '2023-08-01 00:00:00'),
('Graphic Design Basics: Core Principles for Visual Design', 'Understand the fundamentals of great design.', 5, 5, 75.00, '2023-10-01 00:00:00', 'published', '2023-09-15 00:00:00', '2023-09-15 00:00:00');
-- For Courses, I've explicitly added updated_at in the INSERT values. If you omit updated_at
-- from the INSERT column list, it will default to created_at value because of ON UPDATE CURRENT_TIMESTAMP
-- behavior with DEFAULT CURRENT_TIMESTAMP. Explicitly setting it gives more control for sample data.

-- 5. Modules Table
INSERT INTO Modules (course_id, title, order_in_course) VALUES
(1, 'Module 1: HTML Basics', 1), (1, 'Module 2: CSS Fundamentals', 2), (1, 'Module 3: JavaScript Essentials', 3),
(2, 'Section 1: Python Setup & Basics', 1), (2, 'Section 2: Data Analysis with Pandas', 2), (2, 'Section 3: Visualization with Matplotlib', 3),
(3, 'Intro to Swift', 1), (3, 'Building UIs with SwiftUI', 2),
(5, 'Understanding Your Camera', 1), (5, 'Composition Techniques', 2), (5, 'Editing with Lightroom', 3),
(6, 'Introduction to Mindfulness', 1), (6, 'Daily Practices', 2),
(7, 'Closures and Scope', 1), (7, 'Asynchronous JavaScript', 2),
(9, 'Getting Started with Compose', 1), (9, 'State Management', 2),
(10, 'Cloud Concepts Overview', 1), (10, 'Security and Compliance', 2), (10, 'AWS Pricing and Billing', 3),
(11, 'Chapter 1: Why Program?', 1), (11, 'Chapter 2: Variables, expressions, and statements', 2), (11, 'Chapter 3: Conditional execution', 3),
(12, 'Node.js Fundamentals', 1), (12, 'Building a REST API', 2),
(13, 'React Basics & Working With Components', 1), (13, 'State & Props', 2), (13, 'Routing with React Router', 3),
(15, 'Elements of Design', 1), (15, 'Principles of Design', 2);

-- 6. Lessons Table
INSERT INTO Lessons (module_id, title, content_type, content_url_or_text, duration_minutes, order_in_module) VALUES
(1, 'Introduction to HTML', 'video', 'http://video.co/html_intro.mp4', 10, 1), (1, 'HTML Tags and Elements', 'text', 'Text content about HTML tags...', 15, 2),
(2, 'CSS Selectors', 'video', 'http://video.co/css_selectors.mp4', 12, 1), (2, 'Box Model', 'quiz', 'Quiz ID: CSSBOX01', 20, 2),
(4, 'Installing Python', 'document', 'http://docs.co/python_install.pdf', 8, 1), (4, 'Your First Python Script', 'video', 'http://video.co/python_script.mp4', 18, 2),
(7, 'Variables and Constants in Swift', 'text', 'Swift basics text content...', 25, 1), (7, 'Control Flow', 'video', 'http://video.co/swift_control.mp4', 22, 2),
(9, 'Aperture, Shutter Speed, ISO', 'video', 'http://video.co/camera_basics.mp4', 30, 1), (9, 'Lenses Explained', 'document', 'http://docs.co/lenses.pdf', 15, 2),
(12, 'What is Mindfulness?', 'text', 'Explanation of mindfulness...', 10, 1), (12, 'Simple Meditation Exercise', 'video', 'http://video.co/meditation1.mp4', 15, 2),
(14, 'Understanding Closures', 'video', 'http://video.co/js_closures.mp4', 25, 1),
(16, 'First Compose App', 'video', 'http://video.co/compose_intro.mp4', 20, 1),
(18, 'What is Cloud Computing?', 'text', 'Cloud concepts text...', 10, 1), (18, 'AWS Global Infrastructure', 'video', 'http://video.co/aws_infra.mp4', 15, 2),
(21, 'Why learn to write programs?', 'video', 'http://video.co/py4e_why.mp4', 10, 1), (21, 'Hardware Architecture', 'text', 'Basic hardware info', 5, 2),
(24, 'Installing Node.js and NPM', 'video', 'http://video.co/node_install.mp4', 8, 1), (24, 'Creating a Simple Server', 'text', 'Code for a basic Node server', 12, 2),
(26, 'What is React?', 'video', 'http://video.co/react_whatis.mp4', 10, 1), (26, 'Creating Your First Component', 'text', 'Component creation tutorial', 15, 2),
(28, 'Line, Shape, Form', 'video', 'http://video.co/design_elements.mp4', 18, 1), (28, 'Color Theory Basics', 'text', 'Introduction to color theory', 20, 2);

-- 7. Enrollments Table
INSERT INTO Enrollments (user_id, course_id, enrollment_date, progress_percentage, completed_at) VALUES
(1, 1, '2022-03-05 10:00:00', 100, '2022-08-15 12:00:00'), (1, 2, '2022-04-10 11:00:00', 75, NULL),
(2, 1, '2022-03-10 14:00:00', 50, NULL), (3, 3, '2022-05-20 09:00:00', 100, '2022-10-01 10:00:00'),
(4, 5, '2023-03-15 10:00:00', 25, NULL), (5, 6, '2023-06-05 12:00:00', 100, '2023-07-01 14:00:00'),
(1, 7, '2023-07-05 13:00:00', 10, NULL), (2, 9, '2023-09-05 15:00:00', 0, NULL),
(6, 1, '2023-02-01 10:00:00', 90, NULL), (7, 2, '2023-03-01 11:00:00', 60, NULL),
(8, 10, '2023-05-10 14:00:00', 100, '2023-09-20 16:00:00'), (9, 11, '2023-06-15 09:30:00', 40, NULL),
(10, 12, '2023-01-20 10:45:00', 80, NULL), (11, 13, '2022-11-05 11:15:00', 100, '2023-03-01 17:00:00'),
(12, 15, '2023-10-05 12:30:00', 15, NULL), (13, 1, '2023-08-10 14:00:00', 5, NULL),
(14, 4, '2023-09-15 16:30:00', 0, NULL), (15, 6, '2023-10-10 09:00:00', 50, NULL),
(1, 11, '2022-06-10 00:00:00', 100, '2022-09-01 00:00:00'), (4, 13, '2023-01-01 00:00:00', 33, NULL);

-- 8. Events Table
INSERT INTO Events (title, description, instructor_id, category_id, start_time, end_time, location_or_url, price, capacity, created_at) VALUES
('Live Q&A: Web Development Trends', 'Ask Alice anything about web dev!', 1, 1, '2023-11-15 18:00:00', '2023-11-15 19:00:00', 'http://zoom.us/live_qa_web', 0.00, 100, '2023-10-26 00:00:00'),
('Workshop: Intro to Machine Learning', 'Hands-on session with Bob.', 2, 2, '2023-12-01 10:00:00', '2023-12-01 16:00:00', 'Room 101, Tech Hub', 49.99, 30, '2023-10-26 00:00:00'),
('Webinar: Building Your First Mobile App', 'Guidance from David.', 3, 3, '2023-11-20 14:00:00', '2023-11-20 15:30:00', 'http://webinar.co/mobile_intro', 19.99, 200, '2023-10-26 00:00:00'),
('Past Event: Startup Pitch Night', 'Entrepreneurs pitched their ideas.', 4, 4, '2023-08-10 19:00:00', '2023-08-10 21:00:00', 'Community Hall', 10.00, 50, '2023-07-01 00:00:00'),
('Upcoming: Photography Walk in the Park', 'Practical session with Grace.', 5, 5, '2024-03-05 09:00:00', '2024-03-05 12:00:00', 'Central Park, Main Entrance', 25.00, 20, '2023-10-01 00:00:00'),
('Online Summit: The Future of Cloud', 'Panel discussion with Ivy and others.', 6, 7, '2023-11-25 09:00:00', '2023-11-25 17:00:00', 'http://cloudsummit.live', 75.00, 500, '2023-10-15 00:00:00'),
('Workshop: Productivity Hacks', 'Learn to manage your time with Jack.', 7, 6, '2024-01-10 13:00:00', '2024-01-10 16:00:00', 'Online via Zoom', 30.00, 40, '2023-09-15 00:00:00'),
('Tech Talk: The Rise of AI (Past)', 'A discussion on AI evolution.', NULL, 2, '2023-05-05 18:00:00', '2023-05-05 19:30:00', 'University Auditorium', 0.00, 150, '2023-04-01 00:00:00'),
('Networking: Creative Professionals Meetup', 'Connect with fellow creatives.', NULL, 5, '2023-12-10 18:00:00', '2023-12-10 20:00:00', 'The Art Gallery Cafe', 5.00, 60, '2023-10-20 00:00:00'),
('Workshop: Intro to React (Happening Soon)', 'A beginner friendly React workshop.', 1, 1, '2023-10-30 10:00:00', '2023-10-30 13:00:00', 'Online', 40.00, 25, '2023-10-25 00:00:00');
-- For Events, created_at is explicitly set now as the DEFAULT CURRENT_TIMESTAMP would apply to start_time/end_time otherwise.

-- 9. EventRegistrations Table
INSERT INTO EventRegistrations (user_id, event_id, registration_date, status) VALUES
(1, 1, '2023-10-20 10:00:00', 'confirmed'), (2, 1, '2023-10-21 11:00:00', 'confirmed'),
(3, 2, '2023-10-15 14:00:00', 'waitlisted'), (4, 2, '2023-10-16 09:00:00', 'confirmed'),
(5, 3, '2023-10-25 12:00:00', 'confirmed'), (6, 4, '2023-08-01 10:00:00', 'confirmed'),
(7, 5, '2023-10-01 11:00:00', 'confirmed'), (1, 6, '2023-10-10 14:00:00', 'confirmed'),
(8, 7, '2023-09-20 15:00:00', 'confirmed'), (9, 8, '2023-04-25 17:00:00', 'confirmed'),
(10, 9, '2023-10-22 08:00:00', 'confirmed'), (11, 10, '2023-10-26 09:30:00', 'confirmed'),
(12, 1, '2023-10-23 11:00:00', 'cancelled'), (13, 2, '2023-10-18 14:30:00', 'confirmed'),
(14, 5, '2023-10-12 16:00:00', 'waitlisted'), (15, 6, '2023-10-11 09:45:00', 'confirmed');