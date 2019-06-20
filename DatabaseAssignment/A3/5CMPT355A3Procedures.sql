-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Ellen Redlick
-- Modified: Lujie Duan


-- add in values for reference tables
CREATE OR REPLACE FUNCTION load_reference_tables()
RETURNS void AS $$
BEGIN
  INSERT INTO countries(id, code, name)
  VALUES ( 1, 'CA', 'Canada'),
         ( 2, 'US', 'United States of America');
          
          
  INSERT INTO provinces(id, code, name)
  VALUES(1, 'SK', 'Saskatchewan'),
   (2, 'AB', 'Alberta'),
   (3, 'MB', 'Manitoba'),
   (4, 'BC', 'British Columbia'),
   (5, 'ON', 'Ontario'),
   (6, 'QB', 'Quebec'),
   (7, 'NB', 'New Brunswick'),
   (8, 'PE', 'Prince Edward Island'),
   (9, 'NS', 'Nova Scotia'),
   (10, 'NL', 'Newfoundland'),
   (11, 'YK', 'Yukon'),
   (12, 'NT', 'Northwest Territories'),
   (13, 'NU', 'Nunavut');

  INSERT INTO pay_types(id, code, name, description)
  VALUES (1, 'H', 'Hourly', 'Employees paid by an hourly rate of pay'),
         (2, 'S', 'Salary', 'Employees paid by a salaried rate of pay');
         
  INSERT INTO pay_frequencies(id,code,name, description)
  VALUES (1, 'B', 'Biweekly', 'Paid every two weeks'),
         (2, 'W', 'Weekly', 'Paid every week'),
         (3, 'M', 'Monthly', 'Paid once a month');
         
  INSERT INTO marital_statuses(id, code, name, description)
  VALUES(1, 'D', 'Divorced', ''),
        (2, 'M', 'Married', ''),
        (3, 'SP', 'Separated', ''),
        (4, 'C', 'Common-Law', ''),
        (5, 'S', 'Single', '');
        
  INSERT INTO employee_types(id,code,name,description)
  VALUES(1, 'REG', 'Regular', ''),
        (2, 'TEMP', 'Temporary', '');
        
  INSERT INTO employment_status_types(id,code,name,description)
  VALUES(1, 'A' ,'Active', ''),
        (2, 'I', 'Inactive', ''),
        (3, 'P', 'Paid Leave', ''),
        (4, 'U', 'Unpaid Leave', ''),
        (5, 'S', 'Suspension', '');
        
  INSERT INTO employee_statuses(id,code,name,description)
  VALUES(1, 'F' ,'Full-time', ''),
        (2, 'P', 'Part-time', ''),
        (3, 'C', 'Casual', '');
    
  INSERT INTO address_types(id,code,name,description)
  VALUES(1, 'HOME', 'Home', ''),
        (2, 'BUS', 'Business', ''); 
        
  INSERT INTO review_ratings(id,review_text,description)
  VALUES(1, 'Does Not Meet', ''),
        (2, 'Needs Improvement', ''),
        (3, 'Meets Expectations', ''),
        (4, 'Exceeds Expectations', ''),
        (5, 'Exceptional', '');
  
  -- See below for alternative way to do this      
  INSERT INTO phone_types(id,code,name,description)
  VALUES(1, 'H', 'Home', ''),
        (2, 'B', 'Business', ''),
        (3, 'M', 'Mobile', '');

  INSERT INTO termination_types(id,code,name,description)
  VALUES(1, 'V', 'Voluntary', ''),
        (2, 'I', 'Involuntary', '');
  
  INSERT INTO termination_reasons(id,code,name,description)
  VALUES(1, 'DEA', 'Death', ''),
        (2, 'JAB', 'Job Abandonmet', ''),
        (3, 'DIS', 'Dismissal', ''),
        (4, 'EOT', 'End of Temporary Assignment', ''),
        (5, 'LAY', 'Layoff', ''),
        (6, 'RET', 'Retirement', ''),
        (7, 'RES', 'Resignation', '');
  
  
END; $$ LANGUAGE plpgsql;

-- An alternative way to do the above INSERT
CREATE OR REPLACE FUNCTION load_phone_types()
RETURNS void AS $$
BEGIN
 
  INSERT INTO phone_types(id,code,name,description)
  SELECT COALESCE((
                SELECT MAX(PT.id) 
                FROM phone_types PT),0) + row_number() OVER () AS id, 
    UPPER(SUBSTRING(LPT.phone_type, 1, 1)),
    LPT.phone_type,
    ''
  FROM (
    SELECT DISTINCT ph1_type AS phone_type
    FROM load_employee_data led
    UNION
    SELECT DISTINCT ph2_type AS phone_type
    FROM load_employee_data led
    UNION
    SELECT DISTINCT ph3_type AS phone_type
    FROM load_employee_data led
    UNION
    SELECT DISTINCT ph4_type AS phone_type
    FROM load_employee_data led) AS LPT
  WHERE LPT.phone_type IS NOT NULL
    AND LPT.phone_type NOT IN (
    SELECT name 
    FROM phone_types);

END; $$ LANGUAGE plpgsql;


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


-- Load all the locations
CREATE OR REPLACE FUNCTION load_locations()
RETURNS void AS $$
DECLARE 
  v_job_locs RECORD;
  v_locs RECORD;
  v_prov_id INT;
  v_country_id INT;
  v_location_id INT;
BEGIN
-- load the locations from the location file
  FOR v_locs IN (SELECT 
                  TRIM(loc_code) loc_code, 
                  TRIM(loc_name) loc_name, 
                  TRIM(street_addr) street_addr, 
                  TRIM(city) city,
                  TRIM(province) province, 
                  TRIM(country) country,
                  REGEXP_REPLACE(UPPER(TRIM(postal_code)), '[^A-Z0-9]', '', 'g') postal_code
                FROM load_locations ll) LOOP
                
    SELECT id 
    INTO v_prov_id
    FROM provinces 
    WHERE name = v_locs.province;
    
    IF v_prov_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid province for record: %', v_locs;
      CONTINUE;
    END IF; 
    
    SELECT id 
    INTO v_country_id 
    FROM countries 
    WHERE name = v_locs.country;
    
    IF v_country_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid country for record: %', v_locs;
      CONTINUE;
    END IF; 
    
    SELECT id 
    INTO v_location_id 
    FROM locations 
    WHERE code = v_locs.loc_code;
    
    IF v_location_id IS NULL THEN
      INSERT INTO locations(code,name,street,city,province_id,country_id,postal_code)
      VALUES (v_locs.loc_code, v_locs.loc_name, v_locs.street_addr, v_locs.city, v_prov_id, v_country_id, v_locs.postal_code);
    ELSE 
      UPDATE locations 
      SET 
        name = v_locs.loc_name, 
        street = v_locs.street_addr,
        city = v_locs.city,
        province_id = v_prov_id,
        country_id = v_country_id, 
        postal_code = v_locs.postal_code
      WHERE id = v_location_id;
    END IF;  
  END LOOP;
END;
$$ language plpgsql;


-- Load all departments
CREATE OR REPLACE FUNCTION load_departments()
RETURNS void AS $$
DECLARE 
  v_req_depts RECORD;
  v_depts RECORD;
  v_mgr RECORD; 
  
  v_location_id INT;
  v_department_id INT; 
  v_mgr_job_id INT;
BEGIN
  FOR v_depts IN (SELECT 
                        TRIM(ld.dept_code) dept_code, 
                        TRIM(ld.dept_name) dept_name,  
                        TRIM(ld.dept_mgr_job_code) dept_mgr_job_code,  
                        TRIM(ld.dept_mgr_job_title) dept_mgr_job_title,
                        TRIM(ld.effective_date) effective_date,
                        TRIM(ld.expiry_date) expiry_date,
                        TRIM(locs.location_code) location_code
                     FROM 
                       load_departments ld, 
                       (SELECT TRIM(led.department_code) department_code, 
                              TRIM(led.location_code) location_code
                        FROM load_employee_data led
                        GROUP BY TRIM(led.department_code), TRIM(led.location_code)) locs 
                     WHERE TRIM(locs.department_code) = TRIM(ld.dept_code)
                       AND EXISTS (SELECT 1
                                   FROM load_locations ll
                                   WHERE TRIM(locs.location_code) = TRIM(ll.loc_code)) ) LOOP
         
    SELECT id 
    INTO v_location_id
    FROM locations 
    WHERE code = v_depts.location_code;
    
    IF v_location_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid location for record: %', vdepts;
      CONTINUE;
    END IF; 
    
    SELECT id 
    INTO v_department_id 
    FROM locations 
    WHERE code = v_depts.dept_code;
    
    IF v_department_id IS NULL THEN
      INSERT INTO departments(code,name,manager_job_id,location_id)
      VALUES (v_depts.dept_code, v_depts.dept_name, NULL, v_location_id)
      RETURNING id INTO v_department_id; 
    ELSE 
      UPDATE departments 
      SET 
        name = v_depts.dept_name, 
        location_id = v_location_id
      WHERE id = v_department_id;
    END IF; 
    
    
    -- find the manager job id 
    FOR v_mgr IN (SELECT id
                FROM jobs
                WHERE code = v_depts.dept_mgr_job_code
                  AND department_id = v_department_id) LOOP
      v_mgr_job_id := mgr.id;    
    END LOOP;
    
    IF v_mgr_job_id IS NOT NULL THEN 
      UPDATE departments 
      SET manager_job_id = v_mgr_job_id 
      WHERE id = v_department_id;  
    END IF;
     
  END LOOP;
END;
$$ language plpgsql;

-- Load all jobs
CREATE OR REPLACE FUNCTION load_jobs() 
RETURNS void AS $$
DECLARE
  v_jobs RECORD;
  v_depts RECORD; 
  
  v_location_id INT;
  v_department_id INT; 
  v_regional_code VARCHAR(10);
  v_job_id INT;
  v_mgr_job_id INT;
  v_pay_type_id INT;
  v_pay_freq_id INT;
  
BEGIN
  -- loop through all the jobs and either insert or update them. 
  FOR v_jobs IN (SELECT 
                   TRIM(led.job_code) job_code, 
                   TRIM(led.job_title) job_title, 
                   TRIM(led.pay_freq) pay_freq, 
                   TRIM(led.pay_type) pay_type, 
                   TRIM(led.supervisor_job_code) supervisor_job_code,
                   TRIM(led.department_code) department_code, 
                   TRIM(led.location_code) location_code, 
                   TO_DATE(TRIM(jobs.effective_date), 'DD/MM/YYYY') effective_date, 
                   TO_DATE(TRIM(jobs.expiry_date), 'DD/MM/YYYY') expiry_date
                 FROM load_employee_data led,
                     (SELECT 
                        lj.effective_date,
                        lj.expiry_date
                      FROM load_jobs lj) jobs 
                 GROUP BY led.job_code, led.job_title, led.pay_freq, 
                          led.pay_type, led.supervisor_job_code, led.department_code, 
                          led.location_code, jobs.effective_date, jobs.expiry_date) LOOP
    
    SELECT id 
    INTO v_location_id 
    FROM locations 
    WHERE code = v_jobs.location_code; 
    
    IF v_location_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid location for record: %', v_jobs;
      CONTINUE;
    END IF; 
    
    SELECT id
    INTO v_department_id
    FROM departments 
    WHERE code = v_jobs.department_code
      AND location_id = v_location_id; 
      
    IF v_department_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid department for record: %', v_jobs;
      CONTINUE;
    END IF;   
         
    SELECT id 
    INTO v_job_id 
    FROM jobs
    WHERE code = v_jobs.job_code
      AND department_id = v_department_id; 
    
    
    SELECT id 
    INTO v_pay_freq_id 
    FROM pay_frequencies 
    WHERE UPPER(name) = UPPER(v_jobs.pay_freq);
    
    IF v_pay_freq_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid pay frequency for record: %', v_jobs;
      CONTINUE;
    END IF; 
  
    SELECT id 
    INTO v_pay_type_id 
    FROM pay_types
    WHERE UPPER(name) = UPPER(v_jobs.pay_type);
    
    IF v_pay_type_id IS NULL THEN 
      RAISE NOTICE 'Record skipped because of invalid pay type for record: %', v_jobs;
      CONTINUE;
    END IF; 
  
    IF v_job_id IS NULL THEN              
      INSERT INTO jobs(code,name, effective_date, expiry_date,department_id,pay_frequency_id, pay_type_id, supervisor_job_id)
      VALUES(v_jobs.job_code, v_jobs.job_title,v_jobs.effective_date,v_jobs.expiry_date,v_department_id,v_pay_freq_id,v_pay_type_id,NULL)
      RETURNING id INTO v_job_id;
    ELSE 
      UPDATE jobs
      SET name = v_jobs.job_title,
          effective_date = v_jobs.effective_date,
          expiry_date = v_jobs.expiry_date,
          department_id = v_department_id,
          pay_frequency_id = v_pay_freq_id,
          pay_type_id = v_pay_type_id
      WHERE id = v_job_id; 
    END IF;
  END LOOP;
  
  --
  -- update supervisor id
  --       
  --  get all the supervisor job codes for each employee job id
  FOR v_jobs IN (SELECT 
                   sup_jobs.code supervisor_job_code, 
                   emp_jobs.id emp_job_id,
                   emp_jobs.code emp_code,
                   emp_dept.id emp_department_id, 
                   emp_locs.id emp_location_id,
                   emp_locs.code emp_location_code
                 FROM 
                   load_employee_data led,
                   jobs sup_jobs, 
                   jobs emp_jobs, 
                   departments emp_dept, 
                   locations emp_locs
                 WHERE TRIM(led.supervisor_job_code) = sup_jobs.code
                   AND TRIM(led.job_code) = emp_jobs.code
                   AND emp_jobs.department_id = emp_dept.id
                   AND emp_dept.location_id = emp_locs.id
                 GROUP BY sup_jobs.code, emp_jobs.id, emp_jobs.code, emp_dept.id, emp_locs.id, emp_locs.code) LOOP
    
    -- there's basically a three-level hierarchy:
    -- local reporting: 
    --    employees reporting to a supervisor at a local level (02-) will report to the supervisor job in the same department
    -- regional reporting:
    --    employees reporting to a supervisor at a regional level (03-) will report to the regional manager in their same region/province
    -- executive reporting:
    --    employees reporting to an executive position (10-) will report to the executive position at headquarters)
    -- 
    IF v_jobs.supervisor_job_code LIKE '02-%' THEN 
      -- get the supervisor job id at the employee's location (but it might be in a different department at that location)
      SELECT j.id
      INTO v_mgr_job_id
      FROM 
        jobs j 
      WHERE j.code = v_jobs.supervisor_job_code 
        AND j.department_id IN (SELECT d.id
                                FROM departments d
                                WHERE d.location_id = v_jobs.emp_location_id);
     
    ELSIF v_jobs.supervisor_job_code LIKE '03-%' THEN 
      v_regional_code := SPLIT_PART(v_jobs.emp_location_code, '-', 1);
      
      -- find the active regional manager job in the selected region
      SELECT j.*, l.code, d.code
      INTO v_mgr_job_id 
      FROM 
        jobs j,
        locations l, 
        departments d, 
        employee_jobs ej
      WHERE l.code LIKE v_regional_code || '%'
        AND j.code = v_jobs.supervisor_job_code
        AND ej.job_id = j.id 
        AND l.id = d.location_id 
        AND d.id = j.department_id
        AND ej.effective_date <= CURRENT_DATE 
        AND COALESCE(ej.expiry_date,CURRENT_DATE+1) > CURRENT_DATE 
      LIMIT 1; 

    ELSIF v_jobs.supervisor_job_code LIKE '10-%' THEN 
      -- this is an executive supervisor at headquarters - just return the job id
      SELECT j.id
      INTO v_mgr_job_id 
      FROM jobs j
      WHERE j.code = v_jobs.supervisor_job_code;
    END IF; 
    
    
    IF v_mgr_job_id IS NULL THEN 
      RAISE NOTICE 'Could not find a manager for this job: %. Supervisor job id was updated to null.', v_jobs;
    END IF; 
    
    
    UPDATE jobs 
    SET supervisor_job_id = v_mgr_job_id
    WHERE id = v_jobs.emp_job_id;
    
  END LOOP;
  -- update deparment mgr id 
  FOR v_depts IN (SELECT 
                    d.id department_id,
                    TRIM(ld.dept_code) department_code,
                    j.id job_id
                  FROM 
                    load_departments ld,
                    jobs j, 
                    departments d
                  WHERE TRIM(ld.dept_mgr_job_code) = j.code
                    AND j.department_id = d.id ) LOOP
    UPDATE departments 
    SET manager_job_id = v_depts.job_id
    WHERE id = v_depts.department_id;
  END LOOP;
  
  
END;
$$ language plpgsql;
 
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
    
     -- get the employee type 
    SELECT id
    INTO v_employee_type_id
    FROM employee_types
    WHERE UPPER(name) = UPPER(v_emp.employee_type);
    
    
    -- get the employee status
    SELECT id
    INTO v_employee_status_id
    FROM employee_statuses
    WHERE UPPER(name) = UPPER(v_emp.employee_status);
    
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
    ELSE 
      -- UPDATE employee_jobs 
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
      AND atype.code = 'HOME';
      
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
      IF v_bus_addr_id IS NULL THEN 
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
      AND atype.code = 'BUS';
      
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



-- Invoke all the functions in the right order
SELECT load_reference_tables();
SELECT load_phone_types();
SELECT load_locations();
SELECT load_departments();
SELECT load_jobs();
SELECT load_employees();






