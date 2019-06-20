-- Author: HAO LI
-- NSID: hal356

--enable triggers
SELECT set_config('session.trigs_enabled','Y',FALSE);

-- test employees
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111111,'Mr.','Eric','','Li','M',511111111,'1971-03-23','2013-05-01',NULL,NULL,3,'vas@gmail.com',1,1,3);
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111112,'Mr.','Duke','Wang','Mike','M',511111112,'1981-04-23','2011-06-30',NULL,'2017-01-01',2,'sdfa@gmail.com',2,2,7);
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111113,'Mr.','Du','Li','Wang','M',511111113,'1959-05-23','1991-07-21','2009-08-08',NULL,4,'asdfa@gmail.com',2,1,2);
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111114,'Mrs.','Ming','Ming','Sun','F',511111114,'1966-06-23','2017-08-11',NULL,NULL,1,'asdf@gmail.com',1,2,4);
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111115,'Mrs.','Treci','','Elsi','F',511111115,'1949-07-23','2011-08-29',NULL,NULL,2,'eqw@gmail.com',2,2,7);
INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,hire_date,rehire_date,termination_date,marital_status_id,home_email,employment_status_id,term_type_id,term_reason_id)
VALUES(111116,'Mr.','Bruce','','Wayne','M',511111116,'1981-08-23','2000-03-21','2012-08-01','2017-04-02',5,'aasf@gmail.com',1,1,6);
UPDATE employees SET first_name = 'Gus' WHERE first_name = 'Ikey';
UPDATE employees SET rehire_date = '2017-09-09' WHERE id = 9;
UPDATE employees SET marital_status_id = 2 WHERE employee_number = '100882';
UPDATE employees SET title = 'Mr.' WHERE id = 454;

-- test employee_jobsDELETE FROM employee_jobs where id = 12;
DELETE FROM employee_jobs WHERE id = 1;
DELETE FROM employee_jobs WHERE employee_id = 52;
DELETE FROM employee_jobs WHERE id = 33;
DELETE FROM employee_jobs WHERE id = 810;
DELETE FROM employee_jobs WHERE id = 67;
INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,standard_hours,employee_type_id,employee_status_id)
VALUES(810,7,'2013-07-01','2019-10-22',19,30,1,3);
INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,standard_hours,employee_type_id,employee_status_id)
VALUES(52,12,'1988-04-22','2017-11-21',30,25,2,3);
INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,standard_hours,employee_type_id,employee_status_id)
VALUES(33,33,'2001-02-21','2014-03-01',131242,15,2,1);
INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,standard_hours,employee_type_id,employee_status_id)
VALUES(2,40,'1959-05-22','2030-07-21',34231,10,1,2);
INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,standard_hours,employee_type_id,employee_status_id)
VALUES(67,19,'2006-09-02','2200-05-11',9913,20,1,1);
UPDATE employee_jobs SET standard_hours = 25 WHERE id = 10;
UPDATE employee_jobs SET pay_amount = 923123 WHERE id = 15;
UPDATE employee_jobs SET expiry_date = '2017-08-17' WHERE employee_id = 744;
UPDATE employee_jobs SET effective_date = '1994-05-16' WHERE employee_id = 9;
UPDATE employee_jobs SET employee_status_id = 2 WHERE id = 65;


