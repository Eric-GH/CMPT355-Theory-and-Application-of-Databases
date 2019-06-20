-- Author: HAO LI
-- NSID: hal356
CREATE  OR REPLACE VIEW report AS
SELECT 
        e.employee_number AS emplid,
        e.title,
        e.first_name AS firstName,
        e.middle_name AS middleName,
        e.last_name AS lastName,
        --change to gender name
        CASE TRIM(UPPER(e.gender)) 
                    WHEN 'M' THEN 'Male'
                    WHEN 'F' THEN 'Female'
                    WHEN 'U' THEN NULL
        END AS gender,
        to_char(e.birth_date, 'YYYY/MM/DD') AS birthdate,
        m.name AS maritalStatus,
        e.ssn AS SSN,
        e.home_email AS homeEmail,
        --change date to string
        to_char(e.hire_date, 'YYYY/MM/DD') AS OrigHireDate,
        to_char(e.rehire_date,'YYYY/MM/DD') AS rehireDate,
        to_char(e.termination_date,'YYYY/MM/DD') AS termDate,
        tt.name AS termType,
        ts.name AS termReason,
        j.name AS jobTitle,
        j.code AS jobCode,
        to_char(ej.effective_date,'YYYY/MM/DD') AS jobStartDt,
        to_char(ej.expiry_date,'YYYY/MM/DD') AS jobEndDt,
        d.code AS departmentCode,
        l.code AS locationCode,
        pf.name AS payFreq,
        pt.name AS payType,
        --change number to dollar sign string
        TO_CHAR(ej_hourly.pay_amount,'FM$999999999990D00') AS hourlyAmount,
        TO_CHAR(ej_salary.pay_amount,'FM$999999999990D00') AS salaryAmount,
        sup_j.code AS supervisorJobCode,
        es.name AS employeeStatus,
        ej.standard_hours AS standardHours,
        et.name AS employeeType,
        est.name AS employmentStatusType,
        er.rating_id AS lastPerformanceRating,
        rr.review_text AS lastPerformanceRatingText,
        er.review_date AS lastPerformanceRatingDate,
        --spilt to find street number
        split_part(ea.street,' ',1) AS homeStreetNum,
        --spilt and count to find street name   
        trim(both (split_part(ea.street,' ',
        length(replace(ea.street,' ','  '))- length(ea.street)+1)) || split_part(ea.street,' ',1) from ea.street) AS homeStreetName,        
        --spilt and count to find street suffix
        split_part(ea.street,' ',
        length(replace(ea.street,' ','  '))- length(ea.street)+1) AS homeStreetSuffix,
        ea.city AS homeCity,
        p.name AS homeState,
        c.name AS homeCountry,
        ea.postal_code AS homeZipCode,       
        split_part(ema.street,' ',1) AS busStreetNum,
        trim(both (split_part(ema.street,' ',
        length(replace(ema.street,' ','  '))- length(ema.street)+1)) || split_part(ema.street,' ',1) from ema.street) AS busStreetName,
        split_part(ema.street,' ',
        length(replace(ema.street,' ','  '))- length(ema.street)+1) AS busStreetSuffix,
        ema.postal_code AS busZipCode,
        ema.city AS busCity,
        p2.name AS busState,
        c2.name AS busCoutry,
        
        (SELECT ph1.country_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 0 LIMIT 1) AS phone1CountryCode,
        (SELECT ph1.area_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 0 LIMIT 1) AS phone1AreaCode,
        (SELECT ph1.ph_number FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 0 LIMIT 1) AS phone1Number,
        (SELECT ph1.extension FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 0 LIMIT 1) AS phone1Extension,
        (SELECT pt.name FROM(SELECT ph1.type_id AS phone_id FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 0 LIMIT 1) AS phone1_id, phone_types pt WHERE pt.id = phone1_id.phone_id) AS phone1Type,
        
        (SELECT ph1.country_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 1 LIMIT 1) AS phone2CountryCode,
        (SELECT ph1.area_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 1 LIMIT 1) AS phone2AreaCode,
        (SELECT ph1.ph_number FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 1 LIMIT 1) AS phone2Number,
        (SELECT ph1.extension FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 1 LIMIT 1) AS phone2Extension,
        (SELECT pt.name FROM(SELECT ph1.type_id AS phone_id FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 1 LIMIT 1) AS phone1_id, phone_types pt WHERE pt.id = phone1_id.phone_id) AS phone2Type,
        
        (SELECT ph1.country_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 2 LIMIT 1) AS phone3CountryCode,
        (SELECT ph1.area_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 2 LIMIT 1) AS phone3AreaCode,
        (SELECT ph1.ph_number FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 2 LIMIT 1) AS phone3Number,
        (SELECT ph1.extension FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 2 LIMIT 1) AS phone3Extension,
        (SELECT pt.name FROM(SELECT ph1.type_id AS phone_id FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 2 LIMIT 1) AS phone1_id, phone_types pt WHERE pt.id = phone1_id.phone_id) AS phone3Type,
        
        (SELECT ph1.country_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 3 LIMIT 1) AS phone4CountryCode,
        (SELECT ph1.area_code FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 3 LIMIT 1) AS phone4AreaCode,
        (SELECT ph1.ph_number FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 3 LIMIT 1) AS phone4Number,
        (SELECT ph1.extension FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 3 LIMIT 1) AS phone4Extension,
        (SELECT pt.name FROM(SELECT ph1.type_id AS phone_id FROM phone_numbers ph1 WHERE ph1.employee_id = e.id OFFSET 3 LIMIT 1) AS phone1_id, phone_types pt WHERE pt.id = phone1_id.phone_id) AS phone4Type
        

FROM employees e 
 JOIN marital_statuses m ON e.marital_status_id = m.id
 JOIN employee_jobs ej ON e.id = ej.employee_id
 JOIN employee_statuses es ON ej.employee_status_id = es.id
 LEFT JOIN termination_types tt ON e.term_type_id = tt.id
 LEFT JOIN termination_reasons ts ON e.term_reason_id = ts.id
 JOIN employee_types et ON ej.employee_type_id = et.id
 LEFT JOIN employment_status_types est ON e.employment_status_id = est.id
 JOIN jobs j ON ej.job_id = j.id
 LEFT JOIN jobs sup_j ON j.supervisor_job_id = sup_j.id
 JOIN departments d ON j.department_id = d.id
 JOIN locations l ON l.id = d.location_id
 JOIN pay_frequencies pf ON j.pay_frequency_id = pf.id
 JOIN pay_types pt ON j.pay_type_id = pt.id
 JOIN phone_types pe ON pe.id = 1
 JOIN phone_types py ON py.id =2
 JOIN phone_types pp oN pp.id = 3
 LEFT JOIN employee_reviews er ON er.employee_id = e.id
 LEFT JOIN review_ratings rr ON rr.id = er.rating_id
 LEFT JOIN employee_jobs ej_hourly ON ej_hourly.job_id = j.id AND j.pay_type_id = 1 AND ej_hourly.employee_id = e.id
 LEFT JOIN employee_jobs ej_salary ON ej_salary.job_id = j.id AND j.pay_type_id = 2 AND ej_salary.employee_id = e.id
 LEFT JOIN emp_addresses ea ON ea.employee_id = e.id AND ea.type_id = 1
 LEFT JOIN emp_addresses ema ON ema.employee_id = e.id AND ema.postal_code != ea.postal_code AND ema.type_id = 2
 LEFT JOIN provinces p ON p.id = ea.province_id
 LEFT JOIN countries c ON c.id = ea.country_id
 LEFT JOIN provinces p2 ON p2.id = ema.province_id
 LEFT JOIN countries c2 ON c2.id = ema.country_id;

SELECT * FROM report;







