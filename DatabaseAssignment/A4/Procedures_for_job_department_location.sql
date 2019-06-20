-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Ellen Redlick
-- Modified: Lujie Duan


SELECT set_config('session.trigs_enabled','N',FALSE); 
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

-- Invoke all the functions in the right order
SELECT load_reference_tables();
SELECT load_phone_types();
SELECT load_locations();
SELECT load_departments();
SELECT load_jobs();






