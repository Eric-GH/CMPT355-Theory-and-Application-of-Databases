-- Author: HAO LI
-- NSID: hal356

--drop triggers
DROP TRIGGER IF EXISTS emp_audit ON employees;
DROP TRIGGER IF EXISTS emp_jobs_audit ON employee_jobs;
DROP TRIGGER IF EXISTS emp_history_trigger ON employees;
DROP TRIGGER IF EXISTS emp_jobs_history_trigger ON employee_jobs;
--drop functions
DROP FUNCTION IF EXISTS process_emp_audit();
DROP FUNCTION IF EXISTS process_emp_jobs_audit();
DROP FUNCTION IF EXISTS process_emp_history();
DROP FUNCTION IF EXISTS process_emp_jobs_history();

SELECT set_config('session.trigs_enabled','Y',FALSE);

-- Audit table's trigger process for employees table
CREATE OR REPLACE FUNCTION process_emp_audit()
RETURNS TRIGGER AS $emp_audit$
DECLARE
v_tigs_enabled VARCHAR(1);
e_marital_status_id INT;
e_employment_status_id INT;
e_term_type_id INT;
e_term_reason_id INT;
e_marital_status VARCHAR(100);
e_employment_status VARCHAR(100);
e_term_type VARCHAR(100);
e_term_reason VARCHAR(100);
BEGIN
  SELECT COALESCE (current_setting('session.trigs_enabled'),'Y')
  INTO v_tigs_enabled;
  IF v_tigs_enabled = 'Y' THEN
        IF (TG_OP = 'DELETE') THEN
                
                --find marital_status id
                SELECT id
                INTO e_marital_status_id
                FROM marital_statuses
                WHERE id = OLD.marital_status_id;
                --check if the marital_status is exist or not
                IF e_marital_status_id IS NULL THEN
                        e_marital_status := NULL;
                ELSE
                        SELECT name
                        INTO e_marital_status
                        FROM marital_statuses
                        WHERE id = e_marital_status_id;
                END IF;
                
                
                --find employment_status id
                SELECT id
                INTO e_employment_status_id
                FROM employment_status_types
                WHERE id = OLD.employment_status_id;
                --check if the employment_status is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_employment_status := NULL;
                ELSE
                        SELECT name
                        INTO e_employment_status
                        FROM employment_status_types
                        WHERE id = e_employment_status_id;
                END IF;
                
                
                --find term_type id
                SELECT id
                INTO e_term_type_id
                FROM termination_types
                WHERE id = OLD.term_type_id;
                --check if the term_type is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_term_type := NULL;
                ELSE
                        SELECT name
                        INTO e_term_type
                        FROM termination_types
                        WHERE id = e_term_type_id;
                END IF;
                
                
                --find term_reason id
                SELECT id
                INTO e_term_reason_id
                FROM termination_reasons
                WHERE id = OLD.term_reason_id;
                --check if the term_reason is exist or not
                IF e_term_reason_id IS NULL THEN
                        e_term_reason := NULL;
                ELSE
                        SELECT name
                        INTO e_term_reason
                        FROM termination_reasons
                        WHERE id = e_term_reason_id;
                END IF;
                
                
                INSERT INTO emp_audit 
                SELECT 
                        user, 
                        now(), 
                        'DELETE', 
                        OLD.id,
                        OLD.employee_number,
                        OLD.title,
                        OLD.first_name,
                        OLD.middle_name,
                        OLD.last_name,
                        OLD.gender,
                        OLD.ssn,
                        OLD.birth_date,
                        OLD.hire_date,
                        OLD.rehire_date,
                        OLD.termination_date,
                        e_marital_status,
                        OLD.home_email,
                        e_employment_status,
                        e_term_type,
                        e_term_reason;
                RETURN OLD;
        ELSEIF (TG_OP = 'UPDATE') THEN
                       
                --find marital_status id
                SELECT id
                INTO e_marital_status_id
                FROM marital_statuses
                WHERE id = NEW.marital_status_id;
                --check if the marital_status is exist or not
                IF e_marital_status_id IS NULL THEN
                        e_marital_status := NULL;
                ELSE
                        SELECT name
                        INTO e_marital_status
                        FROM marital_statuses
                        WHERE id = e_marital_status_id;
                END IF;
                
                
                --find employment_status id
                SELECT id
                INTO e_employment_status_id
                FROM employment_status_types
                WHERE id = NEW.employment_status_id;
                --check if the employment_status is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_employment_status := NULL;
                ELSE
                        SELECT name
                        INTO e_employment_status
                        FROM employment_status_types
                        WHERE id = e_employment_status_id;
                END IF;
                
                
                --find term_type id
                SELECT id
                INTO e_term_type_id
                FROM termination_types
                WHERE id = NEW.term_type_id;
                --check if the term_type is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_term_type := NULL;
                ELSE
                        SELECT name
                        INTO e_term_type
                        FROM termination_types
                        WHERE id = e_term_type_id;
                END IF;
                
                
                --find term_reason id
                SELECT id
                INTO e_term_reason_id
                FROM termination_reasons
                WHERE id = NEW.term_reason_id;
                --check if the term_reason is exist or not
                IF e_term_reason_id IS NULL THEN
                        e_term_reason := NULL;
                ELSE
                        SELECT name
                        INTO e_term_reason
                        FROM termination_reasons
                        WHERE id = e_term_reason_id;
                END IF;
                
                
                INSERT INTO emp_audit 
                SELECT 
                        user, 
                        now(), 
                        'UPDATE', 
                        NEW.id,
                        NEW.employee_number,
                        NEW.title,
                        NEW.first_name,
                        NEW.middle_name,
                        NEW.last_name,
                        NEW.gender,
                        NEW.ssn,
                        NEW.birth_date,
                        NEW.hire_date,
                        NEW.rehire_date,
                        NEW.termination_date,
                        e_marital_status,
                        NEW.home_email,
                        e_employment_status,
                        e_term_type,
                        e_term_reason;
                RETURN NEW;
        ELSEIF (TG_OP = 'INSERT') THEN
                --find marital_status id
                SELECT id
                INTO e_marital_status_id
                FROM marital_statuses
                WHERE id = NEW.marital_status_id;
                --check if the marital_status is exist or not
                IF e_marital_status_id IS NULL THEN
                        e_marital_status := NULL;
                ELSE
                        SELECT name
                        INTO e_marital_status
                        FROM marital_statuses
                        WHERE id = e_marital_status_id;
                END IF;
                
                
                --find employment_status id
                SELECT id
                INTO e_employment_status_id
                FROM employment_status_types
                WHERE id = NEW.employment_status_id;
                --check if the employment_status is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_employment_status := NULL;
                ELSE
                        SELECT name
                        INTO e_employment_status
                        FROM employment_status_types
                        WHERE id = e_employment_status_id;
                END IF;
                
                
                --find term_type id
                SELECT id
                INTO e_term_type_id
                FROM termination_types
                WHERE id = NEW.term_type_id;
                --check if the term_type is exist or not
                IF e_employment_status_id IS NULL THEN
                        e_term_type := NULL;
                ELSE
                        SELECT name
                        INTO e_term_type
                        FROM termination_types
                        WHERE id = e_term_type_id;
                END IF;
                
                
                --find term_reason id
                SELECT id
                INTO e_term_reason_id
                FROM termination_reasons
                WHERE id = NEW.term_reason_id;
                --check if the term_reason is exist or not
                IF e_term_reason_id IS NULL THEN
                        e_term_reason := NULL;
                ELSE
                        SELECT name
                        INTO e_term_reason
                        FROM termination_reasons
                        WHERE id = e_term_reason_id;
                END IF;
                
                
                INSERT INTO emp_audit 
                SELECT 
                        user, 
                        now(), 
                        'INSERT', 
                        NEW.id,
                        NEW.employee_number,
                        NEW.title,
                        NEW.first_name,
                        NEW.middle_name,
                        NEW.last_name,
                        NEW.gender,
                        NEW.ssn,
                        NEW.birth_date,
                        NEW.hire_date,
                        NEW.rehire_date,
                        NEW.termination_date,
                        e_marital_status,
                        NEW.home_email,
                        e_employment_status,
                        e_term_type,
                        e_term_reason;
                RETURN NEW;
        END IF;
     END IF;
   RETURN NULL;
END;
$emp_audit$ LANGUAGE plpgsql;



-- Audit table's trigger process for employee_jobs table
CREATE OR REPLACE FUNCTION process_emp_jobs_audit()
RETURNS TRIGGER AS $emp_jobs_audit$
DECLARE
v_tigs_enabled VARCHAR(1);
ej_job_id INT;
ej_emp_type_id INT;
ej_emp_status_id INT;

ej_job_title VARCHAR(100);
ej_emp_type VARCHAR(100);
ej_emp_status VARCHAR(100);
BEGIN
  SELECT COALESCE (current_setting('session.trigs_enabled'),'Y')
  INTO v_tigs_enabled;
  IF v_tigs_enabled = 'Y' THEN
        IF (TG_OP = 'DELETE') THEN
                -- find job id
                SELECT id
                INTO ej_job_id
                FROM jobs
                WHERE id = OLD.job_id;
                
                --check job is exist or not
                IF ej_job_id IS NULL THEN
                        ej_job_title := NULL;
                ELSE
                        SELECT j.name
                        INTO ej_job_title
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                END IF;
                
                 -- find employee type id
                SELECT id
                INTO ej_emp_type_id
                FROM employee_types
                WHERE id = OLD.employee_type_id;
                
                --check the employee type is exist or not
                IF ej_emp_type_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT et.name
                        INTO ej_emp_type
                        FROM employee_types et
                        WHERE et.id = ej_emp_type_id;
                END IF;
                
                
                 -- find employee status id
                SELECT id
                INTO ej_emp_status_id
                FROM employee_statuses
                WHERE id = OLD.employee_status_id;
                
                --check the employee status is exist or not
                IF ej_emp_status_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT es.name
                        INTO ej_emp_status
                        FROM employee_statuses es
                        WHERE es.id = ej_emp_status_id;
                END IF;
                
                INSERT INTO emp_jobs_audit
                SELECT 
                        user,
                        now(),
                        'DELETE',
                        OLD.employee_id,
                        ej_job_title,
                        OLD.effective_date,
                        OLD.expiry_date,
                        OLD.pay_amount,
                        OLD.standard_hours,
                        ej_emp_type,
                        ej_emp_status;
                RETURN OLD;
        ELSEIF (TG_OP = 'UPDATE') THEN
                -- find job id
                SELECT id
                INTO ej_job_id
                FROM jobs
                WHERE id = NEW.job_id;
                
                --check job is exist or not
                IF ej_job_id IS NULL THEN
                        ej_job_title := NULL;
                ELSE
                        SELECT j.name
                        INTO ej_job_title
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                END IF;
                
                 -- find employee type id
                SELECT id
                INTO ej_emp_type_id
                FROM employee_types
                WHERE id = NEW.employee_type_id;
                
                --check the employee type is exist or not
                IF ej_emp_type_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT et.name
                        INTO ej_emp_type
                        FROM employee_types et
                        WHERE et.id = ej_emp_type_id;
                END IF;
                
                
                 -- find employee status id
                SELECT id
                INTO ej_emp_status_id
                FROM employee_statuses
                WHERE id = NEW.employee_status_id;
                
                --check the employee status is exist or not
                IF ej_emp_status_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT es.name
                        INTO ej_emp_status
                        FROM employee_statuses es
                        WHERE es.id = ej_emp_status_id;
                END IF;
                
                INSERT INTO emp_jobs_audit
                SELECT 
                        user,
                        now(),
                        'UPDATE',
                        NEW.employee_id,
                        ej_job_title,
                        NEW.effective_date,
                        NEW.expiry_date,
                        NEW.pay_amount,
                        NEW.standard_hours,
                        ej_emp_type,
                        ej_emp_status;
                RETURN NEW;
        ELSEIF (TG_OP = 'INSERT') THEN
                -- find job id
                SELECT id
                INTO ej_job_id
                FROM jobs
                WHERE id = NEW.job_id;
                
                --check job is exist or not
                IF ej_job_id IS NULL THEN
                        ej_job_title := NULL;
                ELSE
                        SELECT j.name
                        INTO ej_job_title
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                END IF;
                
                 -- find employee type id
                SELECT id
                INTO ej_emp_type_id
                FROM employee_types
                WHERE id = NEW.employee_type_id;
                
                --check the employee type is exist or not
                IF ej_emp_type_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT et.name
                        INTO ej_emp_type
                        FROM employee_types et
                        WHERE et.id = ej_emp_type_id;
                END IF;
                
                
                 -- find employee status id
                SELECT id
                INTO ej_emp_status_id
                FROM employee_statuses
                WHERE id = NEW.employee_status_id;
                
                --check the employee status is exist or not
                IF ej_emp_status_id IS NULL THEN
                        ej_emp_type := NULL;
                ELSE
                        SELECT es.name
                        INTO ej_emp_status
                        FROM employee_statuses es
                        WHERE es.id = ej_emp_status_id;
                END IF;
                
                INSERT INTO emp_jobs_audit
                SELECT 
                        user,
                        now(),
                        'INSERT',
                        NEW.employee_id,
                        ej_job_title,
                        NEW.effective_date,
                        NEW.expiry_date,
                        NEW.pay_amount,
                        NEW.standard_hours,
                        ej_emp_type,
                        ej_emp_status;
                RETURN NEW;
        END IF;
    END IF;
  RETURN NULL;
END;
$emp_jobs_audit$ LANGUAGE plpgsql;





--CREATE 'FIRST' TRIGGER PROCESS FOR employees TABLE INTO history table
CREATE OR REPLACE FUNCTION process_emp_history()
RETURNS TRIGGER AS $emp_history_trigger$
DECLARE
emp RECORD;
v_tigs_enabled VARCHAR(1);
e_id INT;
m_id INT;
es_id INT;
ts_id INT;
tt_id INT;
j_id INT;
ej_id INT;
et_id INT;
est_id INT;
d_id INT;

e_term_type_id INT;
e_term_reason_id INT;
e_employment_status_id INT;
ej_employee_status_id INT;
ej_employee_type_id INT;
ej_job_id INT;
j_department_id INT;

e_firstName VARCHAR(100);
e_middleName VARCHAR(100);
e_lastName VARCHAR(100);
e_gender VARCHAR(100);
e_ssn VARCHAR(100);
e_birthdate DATE;
m_marital_status VARCHAR(100);
es_employee_statuses VARCHAR(100);
e_hire_date DATE;
e_rehire_date DATE;
e_termination_date DATE;
ts_termination_reason VARCHAR(100);
tt_termination_type VARCHAR(100);
j_job_code VARCHAR(100);
j_job_title VARCHAR(100);
j_job_start_date DATE;
j_job_end_date DATE;
ej_pay_amount INT;
ej_standard_hours INT;
et_employee_type VARCHAR(100);
est_employment_status VARCHAR(100);
d_department_code VARCHAR(100);
BEGIN
  SELECT COALESCE (current_setting('session.trigs_enabled'),'Y')
  INTO v_tigs_enabled;
  IF v_tigs_enabled = 'Y' THEN  
        IF (TG_OP = 'INSERT') THEN
                --find the employee id
                SELECT id
                INTO e_id
                FROM employees
                WHERE id = NEW.id;
                
                IF e_id IS NULL THEN
                        RAISE NOTICE 'Did not found this employee: %', emp;
                ELSE
                        
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
                END IF;    
                
                --find the marital_statuses id
                SELECT id
                INTO m_id
                FROM marital_statuses
                WHERE id = e_id;
                
                --check the m_id exist or not
                IF m_id IS NULL THEN
                        m_marital_status := NULL;
                ELSE
                        SELECT m.name
                        INTO m_marital_status
                        FROM marital_statuses m
                        WHERE m.id = e_id;
        
                END IF;
                -- find employee_jobs id
                SELECT id
                INTO ej_id
                FROM employee_jobs
                WHERE employee_id = e_id;
                
                --check the employee_jobs id is null or not
                IF ej_id IS NULL THEN
                        ej_pay_amount := NULL;
                        ej_standard_hours := NULL;
                        j_job_start_date := NULL;
                        j_job_end_date := NULL;
                ELSE
                        
                        SELECT effective_date
                        INTO j_job_start_date
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        SELECT expiry_date
                        INTO j_job_end_date
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        SELECT pay_amount
                        INTO    ej_pay_amount
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        SELECT standard_hours
                        INTO  ej_standard_hours
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        SELECT employee_status_id
                        INTO ej_employee_status_id
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        SELECT job_id
                        INTO ej_job_id
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                        
                        SELECT employee_type_id
                        INTO ej_employee_type_id
                        FROM employee_jobs
                        WHERE employee_id = e_id;
                        
                END IF;
                 
                 
                --find employee_statuses id
                SELECT id
                INTO es_id
                FROM employee_statuses
                WHERE id = ej_employee_status_id;
                 
                --check the employee_statuses is null or not
                IF es_id IS NULL THEN
                        es_employee_statuses := NULL;
                ELSE
                        SELECT es.name
                        INTO es_employee_statuses
                        FROM employee_statuses es
                        WHERE es.id = ej_employee_status_id;
                END IF;
                 
                 
                --find termination_reason id
                SELECT id 
                INTO ts_id
                FROM termination_reasons
                WHERE id = e_term_reason_id; 
                        
                -- check the termination reason is null or not
                IF ts_id IS NULL THEN
                        ts_termination_reason := NULL;
                ELSE
                        SELECT ts.name
                        INTO ts_termination_reason
                        FROM termination_reasons ts
                        WHERE ts.id = e_term_reason_id;
                END IF;
                
                --find termination_type id
                SELECT id 
                INTO tt_id
                FROM termination_types
                WHERE id = e_term_type_id;
                        
                -- check the termination type is null or not
                IF tt_id IS NULL THEN
                        tt_termination_type := NULL;
                ELSE
                        SELECT tt.name
                        INTO tt_termination_type
                        FROM termination_types tt
                        WHERE tt.id = e_term_type_id;
                END IF;
                
                 
                --find jobs id
                SELECT id 
                INTO j_id
                FROM jobs
                WHERE id = ej_job_id;
                        
                -- check the jobs is null or not
                IF ts_id IS NULL THEN
                        j_job_code := NULL;
                        j_job_title := NULL;
                ELSE
                        SELECT j.code
                        INTO j_job_code
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                        
                        SELECT j.name
                        INTO j_job_title
                        FROM jobs j
                        WHERE j.id = ej_job_id;                       
                        
                        SELECT j.department_id
                        INTO j_department_id
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                END IF;  
                       
                --find employee type id
                SELECT id 
                INTO et_id
                FROM employee_types
                WHERE id = ej_employee_type_id;
                
                --check the employee type is null or not
                IF et_id IS NULL THEN
                        et_employee_type := NULL;
                ELSE
                        SELECT et.name
                        INTO et_employee_type
                        FROM employee_types et
                        WHERE et.id = ej_employee_type_id;     
                
                END IF;
                
                
                --find employment statuses id
                SELECT id 
                INTO est_id
                FROM employment_status_types
                WHERE id = e_employment_status_id;
                
                --check the employment statuses is null or not
                IF et_id IS NULL THEN
                        est_employment_status := NULL;
                ELSE
                        SELECT est.name
                        INTO est_employment_status
                        FROM employment_status_types est
                        WHERE est.id = e_employment_status_id;     
                
                END IF;
                
                
                 --find department id
                SELECT id 
                INTO d_id
                FROM departments
                WHERE id = j_department_id;
                
                --check the department is null or not
                IF et_id IS NULL THEN
                        d_department_code := NULL;
                ELSE
                        SELECT d.code
                        INTO d_department_code
                        FROM departments d
                        WHERE d.id = j_department_id;    
                
                END IF;
                
                       
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employees',
                'INSERT',
                NEW.first_name,
                NEW.middle_name,
                NEW.last_name, 
                NEW.gender,
                NEW.ssn,
                NEW.birth_date,
                m_marital_status,
                es_employee_statuses,
                NEW.hire_date,
                NEW.rehire_date,
                NEW.termination_date,
                ts_termination_reason,
                tt_termination_type,
                j_job_code,
                j_job_title,
                j_job_start_date,
                j_job_end_date,
                ej_pay_amount,
                ej_standard_hours,
                et_employee_type,
                est_employment_status,
                d_department_code;
                RETURN NEW;
         
        ELSEIF (TG_OP = 'UPDATE') THEN
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employees',
                'UPDATE',
                n.first_name,
                n.middle_name,
                n.last_name,
                n.gender,
                n.ssn,
                n.birth_date,
                n.marital_status,
                n.employee_statuses,
                n.hire_date,
                n.rehire_date,
                n.termination_date,
                n.termination_reason,
                n.termination_type,
                n.job_code,
                n.job_title,
                n.job_start_date,
                n.job_end_date,
                n.pay_amount,
                n.standard_hours,
                n.employee_type,
                n.employment_status,
                n.department_code
                FROM
                (SELECT
                        e.first_name,
                        e.middle_name,
                        e.last_name,
                        e.gender,
                        e.ssn,
                        e.birth_date,
                        m.name AS marital_status,
                        es.name AS employee_statuses,
                        e.hire_date,
                        e.rehire_date,
                        e.termination_date,
                        ts.name AS termination_reason,
                        tt.name AS termination_type,
                        j.code AS job_code,
                        j.name AS job_title,
                        ej.effective_date AS job_start_date,
                        ej.expiry_date AS job_end_date,
                        ej.pay_amount,
                        ej.standard_hours,
                        et.name AS employee_type,
                        est.name AS employment_status,
                        d.code AS department_code
                FROM employees e 
                 JOIN marital_statuses m ON e.marital_status_id = m.id
                 JOIN employee_jobs ej ON e.id = ej.employee_id
                 JOIN employee_statuses es ON ej.employee_status_id = es.id
                 LEFT JOIN termination_types tt ON e.term_type_id = tt.id
                 LEFT JOIN termination_reasons ts ON e.term_reason_id = ts.id
                 JOIN employee_types et ON ej.employee_type_id = et.id
                 LEFT JOIN employment_status_types est ON e.employment_status_id = est.id
                 JOIN jobs j ON ej.job_id = j.id
                 JOIN departments d ON j.department_id = d.id
                 WHERE e.id = NEW.id) AS n;
              RETURN NEW;
        ELSEIF (TG_OP = 'DELETE') THEN
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employees',
                'DELETE',
                n.first_name,
                n.middle_name,
                n.last_name,
                n.gender,
                n.ssn,
                n.birth_date,
                n.marital_status,
                n.employee_statuses,
                n.hire_date,
                n.rehire_date,
                n.termination_date,
                n.termination_reason,
                n.termination_type,
                n.job_code,
                n.job_title,
                n.job_start_date,
                n.job_end_date,
                n.pay_amount,
                n.standard_hours,
                n.employee_type,
                n.employment_status,
                n.department_code
                FROM
                (SELECT 
                        OLD.first_name,
                        OLD.middle_name,
                        OLD.last_name,
                        OLD.gender,
                        OLD.ssn,
                        OLD.birth_date,
                        m.name AS marital_status,
                        es.name AS employee_statuses,
                        OLD.hire_date,
                        OLD.rehire_date,
                        OLD.termination_date,
                        ts.name AS termination_reason,
                        tt.name AS termination_type,
                        j.code AS job_code,
                        j.name AS job_title,
                        ej.effective_date AS job_start_date,
                        ej.expiry_date AS job_end_date,
                        ej.pay_amount,
                        ej.standard_hours,
                        et.name AS employee_type,
                        est.name AS employment_status,
                        d.code AS department_code
                FROM employee_jobs ej 
                 JOIN marital_statuses m ON OLD.marital_status_id = m.id
                 JOIN employee_statuses es ON ej.employee_status_id = es.id
                 LEFT JOIN termination_types tt ON OLD.term_type_id = tt.id
                 LEFT JOIN termination_reasons ts ON OLD.term_reason_id = ts.id
                 JOIN employee_types et ON ej.employee_type_id = et.id
                 LEFT JOIN employment_status_types est ON OLD.employment_status_id = est.id
                 JOIN jobs j ON ej.job_id = j.id
                 JOIN departments d ON j.department_id = d.id
                 WHERE OLD.id = ej.employee_id) AS n;
              RETURN OLD;
        END IF;
        
  END IF;
  RETURN NULL;
END;
$emp_history_trigger$ LANGUAGE plpgsql;







--CREATE 'SECOND' TRIGGER PROCESS FOR employee_jobs TABLE INTO history table                
CREATE OR REPLACE FUNCTION process_emp_jobs_history()
RETURNS TRIGGER AS $emp_jobs_history_trigger$
DECLARE
emp RECORD;
v_tigs_enabled VARCHAR(1);
e_id INT;
m_id INT;
es_id INT;
ts_id INT;
tt_id INT;
j_id INT;
ej_id INT;
et_id INT;
est_id INT;
d_id INT;
ej_employee_id INT;
e_term_type_id INT;
e_term_reason_id INT;
e_employment_status_id INT;
ej_employee_status_id INT;
ej_employee_type_id INT;
ej_job_id INT;
j_department_id INT;

e_firstName VARCHAR(100);
e_middleName VARCHAR(100);
e_lastName VARCHAR(100);
e_gender VARCHAR(100);
e_ssn VARCHAR(100);
e_birthdate DATE;
m_marital_status VARCHAR(100);
es_employee_statuses VARCHAR(100);
e_hire_date DATE;
e_rehire_date DATE;
e_termination_date DATE;
ts_termination_reason VARCHAR(100);
tt_termination_type VARCHAR(100);
j_job_code VARCHAR(100);
j_job_title VARCHAR(100);
j_job_start_date DATE;
j_job_end_date DATE;
ej_pay_amount INT;
ej_standard_hours INT;
et_employee_type VARCHAR(100);
est_employment_status VARCHAR(100);
d_department_code VARCHAR(100);
BEGIN
  SELECT COALESCE (current_setting('session.trigs_enabled'),'Y')
  INTO v_tigs_enabled;
  IF v_tigs_enabled = 'Y' THEN
        IF (TG_OP = 'INSERT') THEN
                -- find employee_jobs id
                SELECT id
                INTO ej_id
                FROM employee_jobs
                WHERE id = NEW.id;
                
                --check the employee_jobs id is null or not
                IF ej_id IS NULL THEN
                        ej_pay_amount := NULL;
                        ej_standard_hours := NULL;
                ELSE
                        SELECT employee_id
                        INTO ej_employee_id
                        FROM employee_jobs
                        WHERE id = ej_id;

                        SELECT employee_status_id
                        INTO ej_employee_status_id
                        FROM employee_jobs
                        WHERE id = ej_id;
                        
                        SELECT job_id
                        INTO ej_job_id
                        FROM employee_jobs
                        WHERE id = ej_id;
                        
                        
                        SELECT employee_type_id
                        INTO ej_employee_type_id
                        FROM employee_jobs
                        WHERE id = ej_id;
                        
                END IF;
                
                --find the employee id
                SELECT id
                INTO e_id
                FROM employees
                WHERE id = ej_employee_id;
                
                IF e_id IS NULL THEN
                        RAISE NOTICE 'Did not found this employee: %', emp;
                ELSE
                        SELECT first_name
                        INTO e_firstName
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT middle_name
                        INTO e_middleName
                        FROM employees
                        WHERE id = e_id;
                        
                        SELECT last_name
                        INTO e_lastName
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

                END IF;    
                
                
                --check the m_id exist or not
                IF m_id IS NULL THEN
                        m_marital_status := NULL;
                ELSE
                        SELECT m.name
                        INTO m_marital_status
                        FROM marital_statuses m
                        WHERE m.id = m_id;
        
                END IF;
                
                 
                 
                --find employee_statuses id
                SELECT id
                INTO es_id
                FROM employee_statuses
                WHERE id = ej_employee_status_id;
                 
                --check the employee_statuses is null or not
                IF es_id IS NULL THEN
                        es_employee_statuses := NULL;
                ELSE
                        SELECT es.name
                        INTO es_employee_statuses
                        FROM employee_statuses es
                        WHERE es.id = ej_employee_status_id;
                END IF;
                 
                 
                --find termination_reason id
                SELECT id 
                INTO ts_id
                FROM termination_reasons
                WHERE id = e_term_reason_id; 
                        
                -- check the termination reason is null or not
                IF ts_id IS NULL THEN
                        ts_termination_reason := NULL;
                ELSE
                        SELECT ts.name
                        INTO ts_termination_reason
                        FROM termination_reasons ts
                        WHERE ts.id = e_term_reason_id;
                END IF;
                
                --find termination_type id
                SELECT id 
                INTO tt_id
                FROM termination_types
                WHERE id = e_term_type_id;
                        
                -- check the termination type is null or not
                IF tt_id IS NULL THEN
                        tt_termination_type := NULL;
                ELSE
                        SELECT tt.name
                        INTO tt_termination_type
                        FROM termination_types tt
                        WHERE tt.id = e_term_type_id;
                END IF;
                
                 
                --find jobs id
                SELECT id 
                INTO j_id
                FROM jobs
                WHERE id = ej_job_id;
                        
                -- check the jobs is null or not
                IF ts_id IS NULL THEN
                        j_job_code := NULL;
                        j_job_title := NULL;
                ELSE
                        SELECT j.code
                        INTO j_job_code
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                        
                        SELECT j.name
                        INTO j_job_title
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                       
                        
                        SELECT j.department_id
                        INTO j_department_id
                        FROM jobs j
                        WHERE j.id = ej_job_id;
                END IF;  
                       
                --find employee type id
                SELECT id 
                INTO et_id
                FROM employee_types
                WHERE id = ej_employee_type_id;
                
                --check the employee type is null or not
                IF et_id IS NULL THEN
                        et_employee_type := NULL;
                ELSE
                        SELECT et.name
                        INTO et_employee_type
                        FROM employee_types et
                        WHERE et.id = ej_employee_type_id;     
                
                END IF;
                
                
                --find employment statuses id
                SELECT id 
                INTO est_id
                FROM employment_status_types
                WHERE id = e_employment_status_id;
                
                --check the employment statuses is null or not
                IF et_id IS NULL THEN
                        est_employment_status := NULL;
                ELSE
                        SELECT est.name
                        INTO est_employment_status
                        FROM employment_status_types est
                        WHERE est.id = e_employment_status_id;     
                
                END IF;
                
                
                 --find department id
                SELECT id 
                INTO d_id
                FROM departments
                WHERE id = j_department_id;
                
                --check the department is null or not
                IF et_id IS NULL THEN
                        d_department_code := NULL;
                ELSE
                        SELECT d.code
                        INTO d_department_code
                        FROM departments d
                        WHERE d.id = j_department_id;    
                
                END IF;
                
                       
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employee_jobs',
                'INSERT',
                e_firstName,
                e_middleName,
                e_lastName,
                e_gender,
                e_ssn,
                e_birthdate,
                m_marital_status,
                es_employee_statuses,
                e_hire_date,
                e_rehire_date,
                e_termination_date,
                ts_termination_reason,
                tt_termination_type,
                j_job_code,
                j_job_title,
                NEW.effective_date,
                NEW.expiry_date,
                NEW.pay_amount,
                NEW.standard_hours,
                et_employee_type,
                est_employment_status,
                d_department_code;
                RETURN NEW;
         
        ELSEIF (TG_OP = 'UPDATE') THEN
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employee_jobs',
                'UPDATE',
                n.first_name,
                n.middle_name,
                n.last_name,
                n.gender,
                n.ssn,
                n.birth_date,
                n.marital_status,
                n.employee_statuses,
                n.hire_date,
                n.rehire_date,
                n.termination_date,
                n.termination_reason,
                n.termination_type,
                n.job_code,
                n.job_title,
                n.job_start_date,
                n.job_end_date,
                n.pay_amount,
                n.standard_hours,
                n.employee_type,
                n.employment_status,
                n.department_code
                FROM
                (SELECT
                        e.first_name,
                        e.middle_name,
                        e.last_name,
                        e.gender,
                        e.ssn,
                        e.birth_date,
                        m.name AS marital_status,
                        es.name AS employee_statuses,
                        e.hire_date,
                        e.rehire_date,
                        e.termination_date,
                        ts.name AS termination_reason,
                        tt.name AS termination_type,
                        j.code AS job_code,
                        j.name AS job_title,
                        ej.effective_date AS job_start_date,
                        ej.expiry_date AS job_end_date,
                        ej.pay_amount,
                        ej.standard_hours,
                        et.name AS employee_type,
                        est.name AS employment_status,
                        d.code AS department_code
                FROM employee_jobs ej 
                 JOIN employees e ON e.id = ej.employee_id
                 JOIN marital_statuses m ON e.marital_status_id = m.id  
                 JOIN employee_statuses es ON ej.employee_status_id = es.id
                 LEFT JOIN termination_types tt ON e.term_type_id = tt.id
                 LEFT JOIN termination_reasons ts ON e.term_reason_id = ts.id
                 JOIN employee_types et ON ej.employee_type_id = et.id
                 LEFT JOIN employment_status_types est ON e.employment_status_id = est.id
                 JOIN jobs j ON ej.job_id = j.id
                 JOIN departments d ON j.department_id = d.id
                 WHERE ej.id = NEW.id) AS n;
              RETURN NEW;
        ELSEIF (TG_OP = 'DELETE') THEN
                INSERT INTO emp_history
                SELECT
                user,
                now(),
                'employee_jobs',
                'DELETE',
                n.first_name,
                n.middle_name,
                n.last_name,
                n.gender,
                n.ssn,
                n.birth_date,
                n.marital_status,
                n.employee_statuses,
                n.hire_date,
                n.rehire_date,
                n.termination_date,
                n.termination_reason,
                n.termination_type,
                n.job_code,
                n.job_title,
                n.job_start_date,
                n.job_end_date,
                n.pay_amount,
                n.standard_hours,
                n.employee_type,
                n.employment_status,
                n.department_code
                FROM
                (SELECT 
                        e.id,
                        e.first_name,
                        e.middle_name,
                        e.last_name,
                        e.gender,
                        e.ssn,
                        e.birth_date,
                        m.name AS marital_status,
                        es.name AS employee_statuses,
                        e.hire_date,
                        e.rehire_date,
                        e.termination_date,
                        ts.name AS termination_reason,
                        tt.name AS termination_type,
                        j.code AS job_code,
                        j.name AS job_title,
                        OLD.effective_date AS job_start_date,
                        OLD.expiry_date AS job_end_date,
                        OLD.pay_amount,
                        OLD.standard_hours,
                        et.name AS employee_type,
                        est.name AS employment_status,
                        d.code AS department_code
                FROM employees e
                 JOIN marital_statuses m ON e.marital_status_id = m.id
                 JOIN employee_statuses es ON OLD.employee_status_id = es.id
                 LEFT JOIN termination_types tt ON e.term_type_id = tt.id
                 LEFT JOIN termination_reasons ts ON e.term_reason_id = ts.id
                 JOIN employee_types et ON OLD.employee_type_id = et.id
                 LEFT JOIN employment_status_types est ON e.employment_status_id = est.id
                 JOIN jobs j ON OLD.job_id = j.id
                 JOIN departments d ON j.department_id = d.id
                 WHERE e.id = OLD.employee_id) AS n;
              RETURN OLD;
        END IF;
  END IF;
  RETURN NULL;
END;
$emp_jobs_history_trigger$ LANGUAGE plpgsql;              



--TIGGER FOR EMPLOYEES' AUDIT TABLE
CREATE TRIGGER emp_audit
AFTER INSERT OR DELETE OR UPDATE ON employees
        FOR EACH ROW EXECUTE PROCEDURE process_emp_audit();


--TIGGER FOR EMPLOYEE_JOBS' AUDIT TABLE
CREATE TRIGGER emp_jobs_audit
AFTER INSERT OR DELETE OR UPDATE ON employee_jobs
        FOR EACH ROW EXECUTE PROCEDURE process_emp_jobs_audit(); 

--TRIGGER FOR EMPLOYEES' HISTORY REPORT TABLE      
CREATE TRIGGER emp_history_trigger
AFTER INSERT OR DELETE OR UPDATE ON employees
        FOR EACH ROW EXECUTE PROCEDURE process_emp_history(); 
             
--TRIGGER FOR EMPLYEE_JOBS' HISTORY REPORT TABLE                
CREATE TRIGGER emp_jobs_history_trigger
AFTER INSERT OR DELETE OR UPDATE ON employee_jobs
        FOR EACH ROW EXECUTE PROCEDURE process_emp_jobs_history();   



         