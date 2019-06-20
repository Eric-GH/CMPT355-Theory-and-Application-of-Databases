-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Lujie Duan

-- Clean the schema
DROP TABLE IF EXISTS marital_statuses CASCADE;
DROP TABLE IF EXISTS employee_types CASCADE;
DROP TABLE IF EXISTS employment_status_types CASCADE;
DROP TABLE IF EXISTS employee_statuses CASCADE;
DROP TABLE IF EXISTS termination_types CASCADE;
DROP TABLE IF EXISTS termination_reasons CASCADE;
DROP TABLE IF EXISTS review_ratings CASCADE;
DROP TABLE IF EXISTS employee_reviews CASCADE;


-- Create
CREATE TABLE marital_statuses(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));


CREATE TABLE employee_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));


CREATE TABLE employment_status_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));


CREATE TABLE employee_statuses(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));


CREATE TABLE termination_types(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));


CREATE TABLE termination_reasons(
  id INT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE review_ratings(
  id INT,
  review_text VARCHAR(1000) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE employee_reviews(
  id SERIAL,
  employee_id INT REFERENCES employees(id) NOT NULL,
  review_date DATE NOT NULL,
  rating_id INT REFERENCES review_ratings(id) NOT NULL,
  PRIMARY KEY (id));


ALTER TABLE employees 
	ADD COLUMN marital_status_id INT REFERENCES marital_statuses(id) NOT NULL,
	ADD COLUMN home_email VARCHAR(200),
  ADD COLUMN employment_status_id INT REFERENCES employment_status_types(id),
	ADD COLUMN term_type_id INT REFERENCES termination_types(id),
	ADD COLUMN term_reason_id INT REFERENCES termination_reasons(id);


ALTER TABLE employee_jobs
	ADD COLUMN employee_type_id INT REFERENCES employee_types(id),
  ADD COLUMN employee_status_id INT REFERENCES employee_statuses(id);
