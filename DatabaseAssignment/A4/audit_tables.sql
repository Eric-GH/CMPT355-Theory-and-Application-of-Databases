-- Author: HAO LI
-- NSID: hal356

-- Clean the schema
DROP TABLE IF EXISTS emp_audit;
DROP TABLE IF EXISTS emp_jobs_audit;
DROP TABLE IF EXISTS emp_history;

-- Audit table for employees
CREATE TABLE emp_audit(
        username TEXT,
        change_date timestamp,
        user_action VARCHAR(1000),
        employee_id INT,
        employee_number VARCHAR(200),
        title VARCHAR(20),
        first_name VARCHAR(100),
        middle_name VARCHAR(100),
        last_name VARCHAR(100),
        gender VARCHAR(200),
        ssn VARCHAR(200),
        birth_date DATE,
        hire_date DATE,
        rehire_date DATE,
        termination_date DATE,
        marital_status VARCHAR(1000),
        home_email VARCHAR(200),
        employment_status VARCHAR(1000),
        term_type VARCHAR(1000),
        term_reason VARCHAR(1000)
        
);


--Audit table for employee_jobs
CREATE TABLE emp_jobs_audit(
        username TEXT,
        change_date timestamp,
        user_action VARCHAR(100),
        employee_id INT,
        job_title VARCHAR(100),
        effective_date DATE,
        expiry_date DATE,
        pay_amount INT,
        standard_hours INT,
        employee_type VARCHAR(100),
        employee_status VARCHAR(100)
);


-- A report table for employees personal information history
CREATE TABLE emp_history(
        user_name TEXT,
        change_time timestamp,
        change_type VARCHAR(1000),
        user_action VARCHAR(1000),
        first_name VARCHAR(100),
        middle_name VARCHAR(100),
        last_name VARCHAR(100),
        gender  VARCHAR(100),
        ssn  VARCHAR(100) NOT NULL,
        birthdate DATE,
        marital_status VARCHAR(100),
        employee_statuses VARCHAR(100),
        hire_date DATE NOT NULL,
        rehire_date DATE,
        termination_date DATE,
        termination_reason VARCHAR(100),
        termination_type VARCHAR(100),
        job_code VARCHAR(100),
        job_title VARCHAR(100),
        job_start_date DATE,
        job_end_date DATE,
        pay_amount INT,
        standard_hours INT,
        employee_type VARCHAR(100),
        employment_status VARCHAR(100),
        department_code VARCHAR(100)
);