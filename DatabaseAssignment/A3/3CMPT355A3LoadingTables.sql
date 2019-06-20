-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Lujie Duan

-- Create loading tables for assignment 3
-- Can use either long VARCHAR() or TEXT for the loading tables 

CREATE TABLE load_employee_data (
    employee_number VARCHAR(1000),
    title VARCHAR(1000),
    first_name VARCHAR(1000),
    middle_name VARCHAR(1000),
    last_name VARCHAR(1000),
    gender VARCHAR(1000),
    birthdate VARCHAR(1000),
    marital_status VARCHAR(1000),
    ssn VARCHAR(1000) ,
    home_email VARCHAR(1000),
    orig_hire_date VARCHAR(1000),
    rehire_date VARCHAR(1000),
    term_date VARCHAR(1000),
    term_type VARCHAR(1000),
    term_reason VARCHAR(1000),
    job_title VARCHAR(1000),
    job_code VARCHAR(1000),
    job_st_date VARCHAR(1000),
    job_end_date VARCHAR(1000),
    department_code VARCHAR(1000),
    location_code VARCHAR(1000),
    pay_freq VARCHAR(1000),
    pay_type VARCHAR(1000),
    hourly_amount VARCHAR(1000),
    salary_amount VARCHAR(1000),
    supervisor_job_code VARCHAR(1000),
    employee_status VARCHAR(1000),
    standard_hours VARCHAR(1000),
    employee_type VARCHAR(1000),
    employment_status VARCHAR(1000),
    last_perf_num VARCHAR(1000),
    last_perf_text VARCHAR(1000) ,
    last_perf_date VARCHAR(1000),
    home_street_num VARCHAR(1000),
    home_street_addr VARCHAR(1000),
    home_street_suffix VARCHAR(1000),
    home_city VARCHAR(1000),
    home_state VARCHAR(1000),
    home_country VARCHAR(1000),
    home_zip_code VARCHAR(1000),
    bus_street_num VARCHAR(1000),
    bus_street_addr VARCHAR(1000),
    bus_street_suffix VARCHAR(1000),
    bus_zip_code VARCHAR(1000),
    bus_city VARCHAR(1000),
    bus_state VARCHAR(1000),
    bus_country VARCHAR(1000),
    ph1_cc VARCHAR(1000),
    ph1_area VARCHAR(1000),
    ph1_number VARCHAR(1000),
    ph1_extension VARCHAR(1000),
    ph1_type VARCHAR(1000),
    ph2_cc VARCHAR(1000),
    ph2_area VARCHAR(1000),
    ph2_number VARCHAR(1000),
    ph2_extension VARCHAR(1000),
    ph2_type VARCHAR(1000),
    ph3_cc VARCHAR(1000),
    ph3_area VARCHAR(1000),
    ph3_number VARCHAR(1000),
    ph3_extension VARCHAR(1000),
    ph3_type VARCHAR(1000),
    ph4_cc VARCHAR(1000),
    ph4_area VARCHAR(1000),
    ph4_number VARCHAR(1000),
    ph4_extension VARCHAR(1000),
    ph4_type VARCHAR(1000)
);


CREATE TABLE load_jobs (
    job_code VARCHAR(1000),
    job_title VARCHAR(1000),
    effective_date VARCHAR(1000),
    expiry_date VARCHAR(1000)
);


CREATE TABLE load_departments (
    dept_code VARCHAR(1000),
    dept_name VARCHAR(1000),
    dept_mgr_job_code VARCHAR(1000),    
    dept_mgr_job_title VARCHAR(1000),
    effective_date VARCHAR(1000),
    expiry_date VARCHAR(1000)
);



CREATE TABLE load_locations (
    loc_code VARCHAR(1000),
    loc_name VARCHAR(1000),
    street_addr VARCHAR(1000),
    city VARCHAR(1000),
    province VARCHAR(1000),
    country VARCHAR(1000),
    postal_code VARCHAR(1000)
);





