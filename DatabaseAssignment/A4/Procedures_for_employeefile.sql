-- Author: HAO LI
-- NSID: hal356

SELECT set_config('session.trigs_enabled','N',FALSE); 
-- Helper function to load phone numbers
CREATE OR REPLACE FUNCTION load_phone_numbers(p_emp_id INT, p_country_code VARCHAR(5), p_area_code VARCHAR(3),
                                              p_ph_number CHAR(7), p_extension VARCHAR(10), p_ph_type VARCHAR(10))
RETURNS void AS  $$
DECLARE
  v_phone_type_id INT;
BEGIN
  
  SELECT id
  INTO v_phone_type_id 
  FROM phone_types 
  WHERE UPPER(name) = UPPER(p_ph_type);
  
  IF v_phone_type_id IS NOT NULL AND p_area_code IS NOT NULL AND p_ph_number IS NOT NULL THEN 
    INSERT INTO phone_numbers(employee_id, country_code,area_code,ph_number,extension,type_id)
    VALUES(p_emp_id,p_country_code,p_area_code,p_ph_number,p_extension,v_phone_type_id);
  ELSE 
    RAISE NOTICE 'Did not insert phone number for record: %', p_ph_number;
  END IF; 
                     
END; $$ language plpgsql;




-- Helper function to check if the employees' information need to update or not
CREATE OR REPLACE FUNCTION load_employees_history(e_number VARCHAR(100),e_title VARCHAR(100),e_first_name VARCHAR(100), e_middle_name VARCHAR(100),e_last_name VARCHAR(100),
e_gender  VARCHAR(100),e_ssn  VARCHAR(100),e_birthdate DATE,e_marital_status_id INT,e_home_email VARCHAR(100),e_employment_status_id INT,e_hire_date DATE,
e_rehire_date DATE,e_termination_date DATE,e_termination_reason_id INT,e_termination_type_id INT)
RETURNS void AS $$
DECLARE
h_id INT;
ej_id INT;
h_marital_status_id INT;
h_employee_status_id INT;
h_job_id INT;
h_employee_type_id INT;
h_employment_status_id INT;
h_termination_reason_id INT;
h_termination_type_id INT;
h_department_id INT;
h_tt_id INT;
h_ts_id INT;

h_marital_status VARCHAR(100);
h_pay_amount INT;
h_standard_hours INT;
h_job_title VARCHAR(100);
h_job_code VARCHAR(100);
h_job_start_date DATE;
h_job_end_date DATE;
h_employee_statuses VARCHAR(100);
h_employee_type VARCHAR(100);
h_employment_status VARCHAR(100);
h_department VARCHAR(100);
h_termination_type VARCHAR(100);
h_termination_reason VARCHAR(100);
BEGIN
        --check the employee information have any changes if need to update
        SELECT e.id
        INTO  h_id
        FROM employees e
        LEFT JOIN employees e1 ON e1.id = e.id AND e1.marital_status_id = e_marital_status_id
        LEFT JOIN employees e2 ON e2.id = e.id AND e2.employment_status_id = e_employment_status_id
        LEFT JOIN employees e3 ON e3.id = e.id AND e3.term_type_id = e_termination_type_id
        LEFT JOIN employees e4 ON e4.id = e.id AND e4.rehire_date = e_rehire_date
        LEFT JOIN employees e5 ON e5.id = e.id AND e5.termination_date = e_termination_date
        LEFT JOIN employees e6 ON e6.id = e.id AND e6.term_reason_id = e_termination_reason_id
        LEFT JOIN employees e7 ON e7.id = e.id AND UPPER(e7.title) = UPPER(e_title)
        WHERE e.employee_number = e_number AND UPPER(e.first_name) = UPPER(e_first_name) AND UPPER(e.middle_name) = UPPER(e_middle_name) 
        AND UPPER(e.last_name) = UPPER(e_last_name) AND UPPER(e.gender) = UPPER(e_gender) AND e.ssn = e_ssn AND e.birth_date = e_birthdate
         AND UPPER(e.home_email) = UPPER(e_home_email)
        AND e.hire_date = e_hire_date;
        
        --if there are something need to update
        IF h_id IS NULL THEN
        
        --start to get employee information
                SELECT id
                INTO h_id
                FROM employees
                WHERE employee_number = e_number;
        
                --find the marital_statuses id
                SELECT id
                INTO h_marital_status_id
                FROM marital_statuses
                WHERE id = e_marital_status_id;
                
                --check the m_id exist or not
                IF h_marital_status_id IS NULL THEN
                        h_marital_status := NULL;
                ELSE
                        SELECT m.name
                        INTO h_marital_status
                        FROM marital_statuses m
                        WHERE m.id = e_marital_status_id;
        
                END IF;
                
                --find employment_status id
                SELECT id
                INTO h_employment_status_id
                FROM employment_status_types
                WHERE id = e_employment_status_id;
                
                
                --find employment status
                IF h_employment_status_id IS NULL THEN
                        h_employment_status := NULL;
                ELSE 
                        SELECT name
                        INTO h_employment_status
                        FROM employment_status_types
                        WHERE id = e_employment_status_id;
                END IF;
        
-- for employee_jobs information                
                
                -- find employee_jobs id
                SELECT id
                INTO ej_id
                FROM employee_jobs
                WHERE employee_id = h_id;
                
                --check the employee_jobs id is null or not
                IF ej_id IS NULL THEN
                        h_pay_amount := NULL;
                        h_standard_hours := NULL;
                        h_job_title := NULL;
                        h_job_code := NULL;
                        h_job_start_date := NULL;
                        h_job_end_date := NULL;
                        h_employee_statuses := NULL;
                        h_employee_type := NULL;
                        
                ELSE
                        --finde job start date
                        SELECT effective_date
                        INTO h_job_start_date
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        --find job end date
                        SELECT expiry_date
                        INTO h_job_end_date
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        --find pay amount
                        SELECT pay_amount
                        INTO h_pay_amount
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        --find standard hours
                        SELECT standard_hours
                        INTO  h_standard_hours
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        --find employee status
                        SELECT employee_status_id
                        INTO h_employee_status_id
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        IF h_employee_status_id IS NULL THEN
                                h_employee_statuses := NULL;
                        ELSE
                                SELECT name
                                INTO h_employee_statuses
                                FROM employee_statuses
                                WHERE id = h_employee_status_id;
                        END IF;
                        
                        --find jobs
                        SELECT job_id
                        INTO h_job_id
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        IF h_job_id IS NULL THEN
                                h_job_title := NULL;
                                h_job_code := NULL;
                        ELSE
                                SELECT code
                                INTO h_job_code
                                FROM jobs
                                WHERE id = h_job_id;
                                
                                SELECT name
                                INTO h_job_title
                                FROM jobs
                                WHERE id = h_job_id;
                                
                                --find department id
                                SELECT department_id
                                INTO h_department_id
                                FROM jobs
                                WHERE id = h_job_id;
                                
                               
                                --find department
                                IF h_department_id IS NULL THEN
                                        h_department := NULL;
                                ELSE
                                        SELECT code
                                        INTO h_department
                                        FROM departments
                                        WHERE id = h_department_id;
                                END IF;
                        END IF;
                        
                        --find employee type
                        SELECT employee_type_id
                        INTO h_employee_type_id
                        FROM employee_jobs
                        WHERE employee_id = h_id;
                        
                        IF h_employee_type_id IS NULL THEN
                                h_employee_type := NULL;
                        ELSE
                                SELECT name
                                INTO h_employee_type
                                FROM employee_types
                                WHERE id = h_employee_type_id;  
                        END IF;                
                        
                END IF;
                
                 --find termination_reason id
                SELECT id 
                INTO h_ts_id
                FROM termination_reasons
                WHERE id = e_termination_reason_id; 
                        
                -- check the termination reason is null or not
                IF h_ts_id IS NULL THEN
                        h_termination_reason := NULL;
                ELSE
                        SELECT name
                        INTO h_termination_reason
                        FROM termination_reasons
                        WHERE id = e_termination_reason_id;
                END IF;
                
                --find termination_type id
                SELECT id 
                INTO h_tt_id
                FROM termination_types
                WHERE id = e_termination_type_id;
                        
                -- check the termination type is null or not
                IF h_tt_id IS NULL THEN
                        h_termination_type := NULL;
                ELSE
                        SELECT name
                        INTO h_termination_type
                        FROM termination_types
                        WHERE id = e_termination_type_id;
                END IF;
                
                
                
             ----------ADD update information to employee_audit table
                INSERT INTO emp_audit
                SELECT
                        user,
                        now(),
                        'UPDATE',
                        h_id,
                        e_number,
                        e_title,
                        e_first_name,
                        e_middle_name,
                        e_last_name,
                        e_gender,
                        e_ssn,
                        e_birthdate,
                        e_hire_date,
                        e_rehire_date,
                        e_termination_date,
                        h_marital_status,
                        e_home_email,
                        h_employment_status,
                        h_termination_reason,
                        h_termination_type;
                        
                
             ----------ADD all update information into history table
                INSERT INTO emp_history
                SELECT
                        user,
                        now(),
                        'employees',
                        'UPDATE',
                        e_first_name,
                        e_middle_name,
                        e_last_name,
                        e_gender,
                        e_ssn,
                        e_birthdate,
                        h_marital_status,
                        h_employee_statuses,
                        e_hire_date,
                        e_rehire_date,
                        e_termination_date,
                        h_termination_reason,
                        h_termination_type,
                        h_job_code,
                        h_job_title,
                        h_job_start_date,
                        h_job_end_date,
                        h_pay_amount,
                        h_standard_hours,
                        h_employee_type,
                        h_employment_status,
                        h_department;
                        
        END IF;    
END;
$$ LANGUAGE plpgsql;





--Helper function to check if the employee_jobs' information need to update or not
CREATE OR REPLACE FUNCTION load_employees_job_history(e_emp_job_id INT,e_emp_id INT,e_job_id INT,e_pay_amount INT,e_standard_hours INT,
e_employee_type_id INT,e_employee_status_id INT,e_job_st_date DATE,e_job_end_date DATE)
RETURNS void AS $$
DECLARE
ej_id INT;
e_id INT;
j_id INT;
d_id INT;
m_id INT;
e_employment_status_id INT;
e_term_type_id INT;
e_term_reason_id INT;

e_first_name VARCHAR(100);
e_middle_name VARCHAR(100);
e_last_name VARCHAR(100);
e_gender VARCHAR(100);
e_ssn VARCHAR(100);
e_birthdate DATE;
e_hire_date DATE;
e_rehire_date DATE;
e_termination_date DATE;

h_marital_status VARCHAR(100);

h_job_title VARCHAR(100);
h_job_code VARCHAR(100);
h_employee_statuses VARCHAR(100);
h_employee_type VARCHAR(100);
h_employment_status VARCHAR(100);
h_department VARCHAR(100);
h_termination_type VARCHAR(100);
h_termination_reason VARCHAR(100);

BEGIN
        SELECT ej.id
        INTO ej_id
        FROM employee_jobs ej
        LEFT JOIN employee_jobs ej1 ON ej1.id = ej.id AND ej1.expiry_date = e_job_end_date
        WHERE ej.id = e_emp_job_id AND ej.employee_id = e_emp_id AND ej.job_id = e_job_id AND ej.pay_amount = e_pay_amount 
        AND ej.standard_hours = e_standard_hours AND ej.employee_type_id = e_employee_type_id AND ej.employee_status_id = e_employee_status_id
        AND ej.effective_date = e_job_st_date;
        
        IF ej_id IS NULL THEN
                --find employee_id
                SELECT id
                INTO e_id
                FROM employees
                WHERE id = e_emp_id;
                --find job_id
                SELECT id
                INTO j_id
                FROM jobs
                WHERE id = e_job_id;
                --find department id
                SELECT department_id
                INTO d_id
                FROM jobs
                WHERE id = e_job_id;
                
                --find department code
                IF d_id IS NULL THEN
                        h_department := NULL;
                ELSE
                        SELECT code
                        INTO h_department
                        FROM departments
                        WHERE id = d_id;
                END IF;        
                
                --find job code  job title
                IF j_id IS NULL THEN
                        h_job_code := NULL;
                        h_job_title := NULL;
                ELSE
                        SELECT code
                        INTO h_job_code
                        FROM jobs
                        WHERE id = j_id;
                        
                        SELECT name
                        INTO h_job_title
                        FROM jobs 
                        WHERE id = j_id;
               END IF;
                
                
                --find employee status                       
                IF e_employee_status_id IS NULL THEN
                        h_employee_statuses := NULL;
                ELSE
                        SELECT name
                        INTO h_employee_statuses
                        FROM employee_statuses
                        WHERE id = e_employee_status_id;
                END IF;
                --find employee type
                IF e_employee_type_id IS NULL THEN
                        h_employee_type := NULL;
                ELSE
                        SELECT name
                        INTO h_employee_type
                        FROM employee_types
                        WHERE id = e_employee_type_id;
                END IF;
                
                        SELECT first_name
                        INTO e_first_name
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT middle_name
                        INTO e_middle_name
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT last_name
                        INTO e_last_name
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT gender
                        INTO e_gender
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT ssn
                        INTO e_ssn
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT birth_date
                        INTO e_birthdate
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT hire_date
                        INTO e_hire_date
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT rehire_date
                        INTO e_rehire_date
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT termination_date
                        INTO e_termination_date
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT term_reason_id
                        INTO e_term_reason_id
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT term_type_id
                        INTO e_term_type_id
                        FROM employees
                        WHERE id = e_id;
                        
                        
                        SELECT employment_status_id
                        INTO e_employment_status_id
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT marital_status_id
                        INTO m_id
                        FROM employees
                        WHERE id = e_id;
                
                --find the marital_statuses id
                IF m_id IS NULL THEN
                        h_marital_status := NULL;
                ELSE
                        SELECT m.name
                        INTO h_marital_status
                        FROM marital_statuses m
                        WHERE m.id = m_id;
        
                END IF;
                
                --find term reason
                IF e_term_reason_id IS NULL THEN
                        h_termination_reason := NULL;
                ELSE
                        SELECT name
                        INTO h_termination_reason
                        FROM termination_reasons
                        WHERE id = e_term_reason_id;
                END IF;
                
                --find term type
                IF e_term_type_id IS NULL THEN
                        h_termination_type := NULL;
                ELSE
                        SELECT name
                        INTO h_termination_type
                        FROM termination_types
                        WHERE id = e_term_type_id;
                        
                END IF;
                
                --find employment status
                IF e_employment_status_id IS NULL THEN
                        h_employment_status := NULL;
                ELSE 
                        SELECT 
                        INTO h_employment_status
                        FROM employment_status_types
                        WHERE id = e_employment_status_id;
                END IF;
                
                --insert update information into emp_job_audit table
                INSERT INTO emp_jobs_audit
                SELECT
                        user,
                        now(),
                        'UPDATE',
                        e_id,
                        h_job_title,
                        e_job_st_date,
                        e_job_end_date,
                        e_pay_amount,
                        e_standard_hours,
                        h_employee_type,
                        h_employee_statuses;
                        
                        
                
                --insert update information into history table
                INSERT INTO emp_history
                SELECT
                        user,
                        now(),
                        'employee_jobs',
                        'UPDATE',
                        e_first_name,
                        e_middle_name,
                        e_last_name,
                        e_gender,
                        e_ssn,
                        e_birthdate,
                        h_marital_status,
                        h_employee_statuses,
                        e_hire_date,
                        e_rehire_date,
                        e_termination_date,
                        h_termination_reason,
                        h_termination_type,
                        h_job_code,
                        h_job_title,
                        
                        e_job_st_date,
                        e_job_end_date,
                        e_pay_amount,
                        e_standard_hours,
                        
                        h_employee_type,
                        h_employment_status,
                        h_department;
                        
                
        END IF;
END;
$$ LANGUAGE plpgsql;











-- Load all employees
CREATE OR REPLACE FUNCTION load_employees()
RETURNS void AS $$
DECLARE
  v_emp RECORD;
  v_empjobs RECORD; 
  v_ssn_rec record;
  
  
  v_emp_id INT;
  v_employment_status_id INT;
  v_term_reason_id INT;
  v_term_type_id INT;
  v_emp_job_id INT;
  v_perf_review_id INT;
  v_employee_type_id INT;
  v_employee_status_id INT;
  v_job_id INT;
  v_home_addr_id INT;
  v_home_prov_id INT;
  v_home_country_id INT;
  v_home_addr_type_id INT;
  v_bus_addr_id INT;
  v_bus_prov_id INT;
  v_bus_country_id INT;
  v_bus_addr_type_id INT;
  v_marital_status_id INT;
  v_location_id INT;
  v_department_id INT; 
  
  
  v_marital_status VARCHAR(100);
  v_term_type VARCHAR(100);
  v_term_reason VARCHAR(100);
  v_employee_type VARCHAR(100);
  v_employee_status VARCHAR(100);
  v_job_code VARCHAR(100);
  v_job_title VARCHAR(100);
  v_employment_status VARCHAR(100);
  v_department_code VARCHAR(100);
BEGIN
  --- insert or update employee data
  FOR v_emp IN (SELECT 
                  TRIM(led.employee_number) employee_number, 
                  TRIM(led.title) title, 
                  TRIM(led.first_name) first_name,
                  TRIM(led.middle_name) middle_name,
                  TRIM(led.last_name) last_name,
                  CASE TRIM(UPPER(led.gender)) 
                    WHEN 'MALE' THEN 'M'
                    WHEN 'FEMALE' THEN 'F'
                    ELSE 'U'
                  END gender,
                  TO_DATE(TRIM(led.birthdate), 'yyyy-mm-dd') birthdate, 
                  TRIM(led.marital_status) marital_status, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ssn)), '[^A-Z0-9]', '', 'g') ssn, 
                  TRIM(led.home_email) home_email, 
                  TO_DATE(TRIM(led.orig_hire_date), 'yyyy-mm-dd') orig_hire_date,
                  TO_DATE(TRIM(led.rehire_date), 'yyyy-mm-dd') rehire_date,
                  TO_DATE(TRIM(led.term_date), 'yyyy-mm-dd') term_date,
                  TRIM(led.term_type) term_type, 
                  TRIM(led.term_reason) term_reason, 
                  TRIM(led.job_code) job_code, 
                  TO_DATE(TRIM(led.job_st_date), 'yyyy-mm-dd') job_st_date,
                  TO_DATE(TRIM(led.job_end_date), 'yyyy-mm-dd') job_end_date,
                  TRIM(led.department_code) department_code, 
                  TRIM(led.location_code) location_code, 
                  TRIM(led.pay_freq) pay_freq,
                  TRIM(led.pay_type) pay_type,
                  COALESCE( TO_NUMBER(TRIM(led.hourly_amount), 'FM99G999G999.00'),
                            TO_NUMBER(TRIM(led.salary_amount), 'FM99G999G999.00') ) pay_amount,
                  TRIM(led.supervisor_job_code) supervisor_job_code, 
                  TRIM(led.employee_status) employee_status, 
                  TRIM(led.standard_hours) standard_hours,
                  TRIM(led.employee_type) employee_type, 
                  TRIM(led.employment_status) employment_status, 
                  TRIM(led.last_perf_num) last_perf_number, 
                  TRIM(led.last_perf_text) last_perf_text, 
                  TO_DATE(TRIM(led.last_perf_date), 'yyyy-mm-dd') last_perf_date, 
                  TRIM(led.home_street_num) home_street_num, 
                  TRIM(led.home_street_addr) home_street_addr, 
                  TRIM(led.home_street_suffix) home_street_suffix,
                  TRIM(led.home_city) home_city,
                  TRIM(led.home_state) home_state,
                  TRIM(led.home_country) home_country,
                  TRIM(led.home_zip_code) home_zip_code,
                  TRIM(led.bus_street_num) bus_street_num,
                  TRIM(led.bus_street_addr) bus_street_addr,
                  TRIM(led.bus_street_suffix) bus_street_suffix,
                  TRIM(led.bus_city) bus_city,
                  TRIM(led.bus_state) bus_state,
                  TRIM(led.bus_country) bus_country,
                  TRIM(led.bus_zip_code) bus_zip_code,
                  REGEXP_REPLACE(UPPER(TRIM(led.ph1_cc)), '[^A-Z0-9]', '', 'g') ph1_cc,
                  REGEXP_REPLACE(UPPER(TRIM(led.ph1_area)), '[^A-Z0-9]', '', 'g') ph1_area,
                  REGEXP_REPLACE(UPPER(TRIM(led.ph1_number)), '[^A-Z0-9]', '', 'g') ph1_number,
                  TRIM(led.ph1_extension) ph1_extension,
                  TRIM(led.ph1_type) ph1_type,  
                  REGEXP_REPLACE(UPPER(TRIM(led.ph2_cc)), '[^A-Z0-9]', '', 'g') ph2_cc, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph2_area)), '[^A-Z0-9]', '', 'g') ph2_area, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph2_number)), '[^A-Z0-9]', '', 'g') ph2_number, 
                  TRIM(led.ph2_extension) ph2_extension, 
                  TRIM(led.ph2_type) ph2_type,  
                  REGEXP_REPLACE(UPPER(TRIM(led.ph3_cc)), '[^A-Z0-9]', '', 'g') ph3_cc, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph3_area)), '[^A-Z0-9]', '', 'g') ph3_area, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph3_number)), '[^A-Z0-9]', '', 'g') ph3_number, 
                  TRIM(led.ph3_extension) ph3_extension, 
                  TRIM(led.ph3_type) ph3_type, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph4_cc)), '[^A-Z0-9]', '', 'g') ph4_cc, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph4_area)), '[^A-Z0-9]', '', 'g') ph4_area, 
                  REGEXP_REPLACE(UPPER(TRIM(led.ph4_number)), '[^A-Z0-9]', '', 'g') ph4_number,
                  TRIM(led.ph4_extension) ph4_extension, 
                  TRIM(led.ph4_type) ph4_type
                FROM load_employee_data led
                ORDER BY led.employee_number) LOOP
    
    -- get the employee number
    SELECT id
    INTO v_emp_id
    FROM employees 
    WHERE employee_number = v_emp.employee_number;

    -- get the employment status 
    SELECT id
    INTO v_employment_status_id
    FROM employment_status_types
    WHERE UPPER(name) = UPPER(v_emp.employment_status);
    
    SELECT id 
    INTO v_term_type_id
    FROM termination_types 
    WHERE UPPER(name) = UPPER(v_emp.term_type);
    
    SELECT id
    INTO v_term_reason_id
    FROM termination_reasons
    WHERE UPPER(name) = UPPER(v_emp.term_reason);
    
    SELECT id
    INTO v_marital_status_id
    FROM marital_statuses 
    WHERE UPPER(name) = UPPER(v_emp.marital_status); 
    
    
    -- if the employee isn't in the database yet...
    IF v_emp_id IS NULL THEN 
    
      -- check to make sure the SSN isn't already in use or null
      FOR v_ssn_rec IN (SELECT id 
                        FROM employees 
                        WHERE ssn = v_emp.ssn) LOOP
        RAISE NOTICE 'ssn already in use. cannot insert record: %', v_emp;
        CONTINUE;                
      END LOOP;
     
      IF v_emp.ssn IS NOT NULL THEN 
        INSERT INTO employees(employee_number,title,first_name,middle_name,last_name,gender,ssn,birth_date,
                              marital_status_id,home_email,employment_status_id,hire_date,rehire_date,termination_date,
                              term_type_id, term_reason_id)
        VALUES (v_emp.employee_number,v_emp.title,v_emp.first_name,v_emp.middle_name,v_emp.last_name,v_emp.gender,
                v_emp.ssn, v_emp.birthdate,v_marital_status_id,v_emp.home_email,v_employment_status_id, 
                v_emp.orig_hire_date,v_emp.rehire_date,v_emp.term_date, v_term_type_id, v_term_reason_id)
        RETURNING id into v_emp_id;
        
        -- get marital_status
        IF v_marital_status_id IS NULL THEN
                v_marital_status := NULL;
        ELSE
                SELECT name
                INTO v_marital_status
                FROM marital_statuses
                WHERE id = v_marital_status_id;
        END IF;        
        
        --get term reason       
        IF v_term_reason_id IS NULL THEN
                v_term_reason := NULL;
        ELSE
                SELECT name
                INTO v_term_reason
                FROM termination_reasons
                WHERE id = v_term_reason_id;
        END IF;
        
        --get term type
        IF v_term_type_id IS NULL THEN
                v_term_type := NULL;
        ELSE
                SELECT name
                INTO v_term_type
                FROM termination_types
                WHERE id = v_term_type_id;
        END IF;
        
        --get employment_status
        IF v_employment_status_id IS NULL THEN
                v_employment_status := NULL;
        ELSE
                SELECT name
                INTO v_employment_status
                FROM employment_status_types
                WHERE id = v_employment_status_id;
        END IF;
               
      ELSE 
        RAISE NOTICE 'Skipping employee record. ssn null for employee: %', v_emp;
        CONTINUE;
      END IF;
    
    ELSE 
    -- if you found the employee number, check to make sure it's the employee number for the right person.
      -- Check to make sure this is the right person
      IF NOT v_emp.ssn = (SELECT ssn 
                          FROM employees
                          WHERE id = v_emp_id) THEN 
        RAISE NOTICE 'This employee number belongs to another employee: %', v_emp;
        CONTINUE;
      END IF;
      PERFORM load_employees_history(v_emp.employee_number,v_emp.title,v_emp.first_name,v_emp.middle_name,v_emp.last_name,v_emp.gender, 
      v_emp.ssn,v_emp.birthdate,v_marital_status_id, v_emp.home_email,v_employment_status_id,v_emp.orig_hire_date,
      v_emp.rehire_date,v_emp.term_date,v_term_type_id,v_term_reason_id);
      UPDATE employees 
      SET 
        title = v_emp.title, 
        first_name = v_emp.first_name, 
        middle_name = v_emp.middle_name,
        last_name = v_emp.last_name, 
        gender = v_emp.gender, 
        ssn = v_emp.ssn, 
        birth_date = v_emp.birthdate,
        marital_status_id = v_marital_status_id, 
        home_email = v_emp.home_email,
        employment_status_id = v_employment_status_id,
        hire_date = v_emp.orig_hire_date, 
        rehire_date = v_emp.rehire_date,
        termination_date = v_emp.term_date,
        term_type_id = v_term_type_id,
        term_reason_id = v_term_reason_id
      WHERE id = v_emp_id;
    END IF;
    
    
    -- 
    -- Performance 
    --
    --  look for an existing review for the employee with the date in the file
    SELECT id
    INTO v_perf_review_id
    FROM employee_reviews
    WHERE employee_id = v_emp_id 
      AND review_date = v_emp.last_perf_date;

    -- if it doesn't exist, insert it. Otherwise, update the rating 
    IF v_perf_review_id IS NULL AND v_emp.last_perf_number IS NOT NULL AND v_emp.last_perf_date IS NOT NULL THEN 
      INSERT INTO employee_reviews(employee_id, review_date, rating_id)
      VALUES (v_emp_id, v_emp.last_perf_date, v_emp.last_perf_number::INT);
    ELSIF v_emp.last_perf_number IS NOT NULL AND v_emp.last_perf_date IS NOT NULL THEN
      UPDATE employee_reviews
      SET rating_id = v_emp.last_perf_number::INT
      WHERE id = v_perf_review_id;
    END IF;
    
    
    --
    --  insert/update into employee jobs
    --
    
     -- get the employee type id
    SELECT id
    INTO v_employee_type_id
    FROM employee_types
    WHERE UPPER(name) = UPPER(v_emp.employee_type);
    
    -- get the employee type
    IF v_employee_type_id IS NULL THEN
        v_employee_type := NULL;
    ELSE
        SELECT name
        INTO v_employee_type
        FROM employee_types
        WHERE id = v_employee_type_id;
    END IF;
    
    
    -- get the employee status id
    SELECT id
    INTO v_employee_status_id
    FROM employee_statuses
    WHERE UPPER(name) = UPPER(v_emp.employee_status);
    
    -- get the employee status 
    IF v_employee_status_id IS NULL THEN
        v_employee_status := NULL;
    ELSE
        SELECT name
        INTO v_employee_status
        FROM employee_statuses
        WHERE id = v_employee_status_id;
    END IF;
    
    -- look for an employee_job for this employee
    v_emp_job_id := NULL;
    FOR v_empjobs IN (SELECT ej.id
                      FROM 
                        employee_jobs ej, 
                        employees e,
                        jobs j
                      WHERE ej.employee_id = e.id 
                        AND e.employee_number = v_emp.employee_number 
                        AND ej.job_id = j.id
                        AND j.code = v_emp.job_code
                        AND v_emp.job_st_date = ej.effective_date) LOOP
      v_emp_job_id := v_empjobs.id;
    END LOOP;
    
    
    
    
    
    -- check to see if there is a job with this job code in this department/location combination.
    SELECT j.id 
    INTO v_job_id
    FROM jobs j
    LEFT JOIN departments d ON j.department_id = d.id
    JOIN locations l ON l.id = d.location_id
    WHERE l.code = v_emp.location_code
      AND UPPER(j.code) = UPPER(v_emp.job_code);

    IF v_job_id IS NULL
    THEN
        RAISE NOTICE 'No job exists with this job code, department, location combination for employee %, "%"', v_emp_id, v_emp.job_code;
        CONTINUE;
    END IF;
    
    -- check if there's an existing open employee job for this employee and job combination 
    --   during this time period. 
    -- If there isn't, then check for an existing open employee job and close it, and then insert a new 
    --   employee job record.
    -- If there is, do an update. 
    IF v_emp_job_id IS NULL THEN 
    
      -- check for existing open employee job and expire it.
      FOR v_empjobs IN (SELECT ej.id
                   FROM employee_jobs ej
                   WHERE ej.expiry_date IS NULL 
                     AND ej.employee_id = v_emp_id) LOOP
        UPDATE employee_jobs
        SET expiry_date = v_emp.job_st_date
        WHERE id = v_empjobs.id;
      END LOOP;
      
      INSERT INTO employee_jobs(employee_id,job_id,effective_date,expiry_date,pay_amount,
                                standard_hours,employee_type_id,employee_status_id)
      VALUES(v_emp_id, v_job_id, v_emp.job_st_date, v_emp.job_end_date, v_emp.pay_amount, v_emp.standard_hours::INT, 
             v_employee_type_id, v_employee_status_id );
      
      IF v_job_id IS NULL THEN
           v_job_code := NULL;
           v_job_title := NULL;
      ELSE
           SELECT code
           INTO v_job_code
           FROM jobs
           WHERE id = v_job_id;
           
           SELECT name
           INTO v_job_title
           FROM jobs
           WHERE id = v_job_id;
           
           SELECT department_id
           INTO v_department_id
           FROM jobs
           WHERE id = v_job_id;
           
           IF v_department_id IS NULL THEN
                v_department_code := NULL;
           ELSE
                SELECT code
                INTO v_department_code
                FROM departments
                WHERE id = v_department_id;
           END IF;
      END IF;
      
      INSERT INTO emp_history
      SELECT    user,
                now(),
                'load_procedures',
                'INSERT',
                v_emp.first_name,
                v_emp.middle_name,
                v_emp.last_name,
                v_emp.gender,
                v_emp.ssn,
                v_emp.birthdate,
                v_marital_status,
                V_employee_status,
                v_emp.orig_hire_date,
                v_emp.rehire_date,
                v_emp.term_date,
                v_term_reason,
                v_term_type,
                v_job_code,
                v_job_title,
                v_emp.job_st_date,
                v_emp.job_end_date,
                v_emp.pay_amount,
                v_emp.standard_hours::INT,
                v_employee_type,
                v_employment_status,
                v_department_code;
                      
    ELSE 
      -- UPDATE employee_jobs 
      PERFORM load_employees_job_history(v_emp_job_id,v_emp_id,v_job_id,v_emp.pay_amount::INT,v_emp.standard_hours::INT,v_employee_type_id,v_employee_status_id,
      v_emp.job_st_date,v_emp.job_end_date);
      UPDATE employee_jobs 
      SET pay_amount = v_emp.pay_amount, 
          standard_hours = v_emp.standard_hours::INT, 
          employee_type_id = v_employee_type_id,
          employee_status_id = v_employee_status_id,
          effective_date = v_emp.job_st_date,
          expiry_date = v_emp.job_end_date
      WHERE id = v_emp_job_id;
    END IF;
    
    
    
    --
    -- load addresses
    --
    
    -- add/update home addresses
    SELECT a.id
    INTO v_home_addr_id 
    FROM 
      emp_addresses a,
      address_types atype
    WHERE a.type_id = atype.id
      AND atype.code = 'HOME'
      AND a.employee_id = v_emp_id;
      
    SELECT id 
    INTO v_home_prov_id
    FROM provinces 
    WHERE UPPER(name) = UPPER(v_emp.home_state);
    
    SELECT id 
    INTO v_home_country_id
    FROM countries 
    WHERE UPPER(name) = UPPER(v_emp.home_country);
                          
    SELECT id 
    INTO v_home_addr_type_id
    FROM address_types 
    WHERE code = 'HOME';
   
    IF v_home_prov_id IS NOT NULL AND v_home_country_id IS NOT NULL THEN 
      IF v_home_addr_id IS NULL THEN 
        INSERT INTO emp_addresses(employee_id, street, city, province_id, country_id, postal_code, type_id) 
        VALUES(v_emp_id, v_emp.home_street_num || ' ' || v_emp.home_street_addr || ' ' || v_emp.home_street_suffix, 
               v_emp.home_city, v_home_prov_id, v_home_country_id, v_emp.home_zip_code, v_home_addr_type_id);
      ELSE 
        UPDATE emp_addresses
        SET street = v_emp.home_street_num || ' ' || v_emp.home_street_addr || ' ' || v_emp.home_street_suffix, 
            city = v_emp.home_city,
            province_id = v_home_prov_id, 
            country_id = v_home_country_id, 
            postal_code = v_emp.home_zip_code
        WHERE id = v_home_addr_id;            
      END IF;
    ELSE 
      RAISE NOTICE 'home province or country not found. Province id: %, Country id: %', v_home_prov_id, v_home_country_id;
    END IF; 
    
    
     -- add/update business addresses
    SELECT a.id
    INTO v_bus_addr_id 
    FROM 
      emp_addresses a,
      address_types atype
    WHERE a.type_id = atype.id
      AND atype.code = 'BUS'
      AND a.employee_id = v_emp_id;
      
    SELECT id 
    INTO v_bus_prov_id
    FROM provinces 
    WHERE UPPER(name) = UPPER(v_emp.bus_state);
    
    SELECT id 
    INTO v_bus_country_id
    FROM countries 
    WHERE UPPER(name) = UPPER(v_emp.bus_country);
                          
    SELECT id 
    INTO v_bus_addr_type_id
    FROM address_types 
    WHERE code = 'BUS'; 
     
    IF v_bus_prov_id IS NOT NULL AND v_bus_country_id IS NOT NULL THEN 
      IF v_bus_addr_id IS NULL THEN 
        INSERT INTO emp_addresses(employee_id, street, city, province_id, country_id, postal_code, type_id) 
        VALUES(v_emp_id, v_emp.bus_street_num || ' ' || v_emp.bus_street_addr || ' ' || v_emp.bus_street_suffix, 
               v_emp.bus_city, v_bus_prov_id, v_bus_country_id, v_emp.bus_zip_code, v_bus_addr_type_id);
      ELSE 
        UPDATE emp_addresses
        SET street = v_emp.bus_street_num || ' ' || v_emp.bus_street_addr || ' ' || v_emp.bus_street_suffix, 
            city = v_emp.bus_city,
            province_id = v_bus_prov_id, 
            country_id = v_bus_country_id, 
            postal_code = v_emp.bus_zip_code
        WHERE id = v_bus_addr_id;      
      END IF;      
    ELSE 
      RAISE NOTICE 'Bussiness province or country not found. Province id: %, Country id: %', v_bus_prov_id, v_bus_country_id;
    END IF;  



    -- 
    -- remove any existing phone numbers for this employee
    --
    DELETE FROM phone_numbers 
    WHERE employee_id = v_emp_id; 
    
    --
    --  load employee phone numbers
    --
    PERFORM load_phone_numbers(v_emp_id,v_emp.ph1_cc,v_emp.ph1_area,v_emp.ph1_number,v_emp.ph1_extension,v_emp.ph1_type);
    PERFORM load_phone_numbers(v_emp_id,v_emp.ph2_cc,v_emp.ph2_area,v_emp.ph2_number,v_emp.ph2_extension,v_emp.ph2_type);
    PERFORM load_phone_numbers(v_emp_id,v_emp.ph3_cc,v_emp.ph3_area,v_emp.ph3_number,v_emp.ph3_extension,v_emp.ph3_type);
    PERFORM load_phone_numbers(v_emp_id,v_emp.ph4_cc,v_emp.ph4_area,v_emp.ph4_number,v_emp.ph4_extension,v_emp.ph4_type);
    
                
   
                
  END LOOP;
  
END;
$$ LANGUAGE plpgsql;
SELECT load_employees();
SELECT set_config('session.trigs_enabled','Y',FALSE); 