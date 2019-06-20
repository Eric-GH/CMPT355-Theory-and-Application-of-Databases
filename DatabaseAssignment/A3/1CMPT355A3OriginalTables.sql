-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Lujie Duan

-- Clean the schema
DROP TABLE IF EXISTS pay_types CASCADE;
DROP TABLE IF EXISTS pay_frequencies CASCADE;
DROP TABLE IF EXISTS phone_types CASCADE;
DROP TABLE IF EXISTS address_types CASCADE;
DROP TABLE IF EXISTS provinces CASCADE;
DROP TABLE IF EXISTS countries CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS phone_numbers CASCADE;
DROP TABLE IF EXISTS emp_addresses CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS employee_jobs CASCADE;

DROP DOMAIN IF EXISTS GENDER;
DROP DOMAIN IF EXISTS SSNTYPE;


-- Create
CREATE DOMAIN GENDER AS VARCHAR(1) 
DEFAULT 'U' 
CHECK (VALUE IN ('M', 'F', 'U', 'N'));

CREATE DOMAIN SSNTYPE AS VARCHAR(11);

CREATE TABLE pay_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE pay_frequencies(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE phone_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,  
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE address_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE provinces(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE countries(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE employees(
  id SERIAL,
  employee_number VARCHAR(200), 
  title VARCHAR(20), 
  first_name VARCHAR(100) NOT NULL,
  middle_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  gender GENDER NOT NULL,
  ssn ssnType NOT NULL,
  birth_date DATE,
  hire_date DATE NOT NULL,
  rehire_date DATE,
  termination_date DATE, 
  PRIMARY KEY(id));

CREATE TABLE phone_numbers(
  id SERIAL,
  employee_id INT NOT NULL REFERENCES employees(id), 
  country_code VARCHAR(3),
  area_code VARCHAR(3),
  ph_number VARCHAR(7),
  extension VARCHAR(8),
  type_id INT NOT NULL REFERENCES phone_types(id), 
  PRIMARY KEY(id));

CREATE TABLE emp_addresses(
  id SERIAL,
  employee_id INT NOT NULL REFERENCES employees(id), 
  street VARCHAR(200),
  city VARCHAR(200),
  province_id INT NOT NULL REFERENCES provinces(id),
  country_id INT NOT NULL REFERENCES countries(id),
  postal_code VARCHAR(7),
  type_id INT NOT NULL REFERENCES address_types(id), 
  PRIMARY KEY(id));

CREATE TABLE locations(
  id SERIAL,
  code VARCHAR(10) NOT NULL UNIQUE,
  name VARCHAR(100),
  street VARCHAR(200) NOT NULL,
  city VARCHAR(200),
  province_id INT NOT NULL REFERENCES Provinces(id),
  country_id INT NOT NULL REFERENCES Countries(id),
  postal_code VARCHAR(7),
  PRIMARY KEY (id));

CREATE TABLE departments(
  id SERIAL,
  code VARCHAR(10) NOT NULL ,
  name VARCHAR(100), 
  location_id INT NOT NULL REFERENCES Locations(id),
  PRIMARY KEY (id));

CREATE TABLE jobs(
  id SERIAL,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  effective_date DATE NOT NULL,
  expiry_date DATE,
  supervisor_job_id INT REFERENCES Jobs(id),
  department_id INT NOT NULL REFERENCES Departments(id), 
  pay_frequency_id INT NOT NULL REFERENCES pay_frequencies(id),
  pay_type_id INT NOT NULL REFERENCES pay_types(id), 
  PRIMARY KEY(id));

CREATE TABLE employee_jobs(
  id SERIAL,
  employee_id INT NOT NULL REFERENCES Employees(id),
  job_id INT NOT NULL REFERENCES Jobs,
  effective_date DATE NOT NULL,
  expiry_date DATE,
  pay_amount INT,
  standard_hours INT,
  PRIMARY KEY (id));

ALTER TABLE Departments 
ADD COLUMN manager_job_id INT REFERENCES Jobs(id);




