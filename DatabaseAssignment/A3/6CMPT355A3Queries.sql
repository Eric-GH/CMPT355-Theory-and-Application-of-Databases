-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Ellen Redlick
-- Modified: Lujie Duan


-- Part 3 query 1:
-- Only show 'Active' employees
SELECT
  e.employee_number, 
  e.last_name || ', ' || e.first_name AS employee_name, 
  e.birth_date, 
  CASE e.gender
    WHEN 'M' THEN 'Male' 
    WHEN 'W' THEN 'Female'
    ELSE 'Unknown' 
  END AS gender, 
  date_part('year', age(COALESCE(e.termination_date, CURRENT_DATE), (COALESCE(e.rehire_date,e.hire_date)))) AS length_of_service, 
  j.name AS job_title, 
  date_part('year', age(CURRENT_DATE, ej.effective_date)) AS length_of_current_job, 
  d.name department_name, 
  l.name location_name, 
  pt.name pay_type, 
  TO_CHAR(ej.pay_amount,'FM$999,999,999,990D00') pay_amount, 
  sup_emp.last_name || ', ' || sup_emp.first_name AS supervisor_name
FROM employees e
  JOIN employee_jobs ej ON e.id = ej.employee_id 
  JOIN jobs j ON ej.job_id = j.id 
  JOIN departments d ON j.department_id = d.id 
  JOIN locations l ON d.location_id = l.id 
  LEFT JOIN jobs sup_job ON sup_job.id = j.supervisor_job_id 
  LEFT JOIN employee_jobs sup_ej ON sup_ej.job_id = sup_job.id
                                 AND CURRENT_DATE BETWEEN sup_ej.effective_date 
                                                  AND COALESCE(sup_ej.expiry_date, CURRENT_DATE+1) -- find the supervisor's current job
  LEFT JOIN employees sup_emp ON sup_emp.id = sup_ej.employee_id
  JOIN pay_types pt ON j.pay_type_id = pt.id
  JOIN employment_status_types est ON est.id = e.employment_status_id
WHERE est.code = 'A'
  AND CURRENT_DATE BETWEEN ej.effective_date AND COALESCE(ej.expiry_date, CURRENT_DATE+1); -- find the current employee job  


-- Part 3, query 2. 
-- top performing employees 
SELECT 
  emp.last_name || ', ' || emp.first_name employee_name, 
  rr.id rating_number,
  rr.review_text, 
  last_perf.review_date, 
  dept.name department_name, 
  loc.name location_name
FROM 
  employees emp, 
  employee_jobs empj, 
  employment_status_types est,
  jobs, 
  employee_reviews last_perf, 
  review_ratings rr, 
  departments dept,
  locations loc,
  -- Return the highest performance rating in each department. 
  (SELECT MAX(rr.id) max_rating, d.id dept_id
  FROM 
    departments d, 
    locations l, 
    employee_reviews er, 
    review_ratings rr,
    employees e, 
    employee_jobs ej,
    jobs j
  WHERE d.id = j.department_id
    AND d.location_id = l.id
    AND j.id = ej.job_id 
    AND ej.employee_id = e.id
    AND e.id = er.employee_id 
    AND rr.id = er.rating_id 
    AND er.review_date = (SELECT MAX(er2.review_date)
                          FROM employee_reviews er2
                          WHERE er2.employee_id = er.employee_id) 
  GROUP BY d.id) dept_max_perf
WHERE emp.id = last_perf.employee_id 
  AND last_perf.rating_id = rr.id
  AND rr.id = dept_max_perf.max_rating
  AND dept.id = dept_max_perf.dept_id
  AND emp.id = empj.employee_id 
  AND empj.job_id = jobs.id 
  AND CURRENT_DATE BETWEEN empj.effective_date AND COALESCE(empj.expiry_date, CURRENT_DATE+1)
  AND jobs.department_id = dept.id 
  AND dept.location_id = loc.id
  AND est.id = emp.employment_status_id
  AND est.code = 'A';
  
-- Part 3 Question 3a
SELECT 
  e.last_name || ', ' || e.first_name employee_name,
  date_part('year', age(CURRENT_DATE, e.birth_date)) employee_age, 
  e.termination_date,
  date_part('year', age(termination_date, COALESCE(hire_date,rehire_date))) length_of_service, 
  tt.name termination_type, 
  tr.name termination_reason
FROM 
  employees e,
  employee_jobs ej,
  employment_status_types est,
  termination_types tt,
  termination_reasons tr
WHERE e.id = ej.employee_id 
  AND e.employment_status_id = est.id
  AND est.code = 'I' 
  AND COALESCE(e.termination_date, CURRENT_DATE+1) < CURRENT_DATE
  AND e.term_type_id = tt.id 
  AND e.term_reason_id = tr.id;
  
 -- PART 3 question 3b
SELECT 
  dept.code department_code, 
  dept.name department_name, 
  loc.name location_name,  
  dept_terms.term_count,
  TO_CHAR((dept_terms.term_count/total_terms.term_count::numeric)*100, 'FM99D00%') AS percentage_terms
FROM 
  departments dept,
  locations loc,
  (SELECT COUNT(*) term_count, d.id dept_id
   FROM
     departments d, 
     employees e,
     employee_jobs ej, 
     jobs j, 
     locations l
   WHERE d.id = j.department_id 
    AND d.location_id = l.id
    AND j.id = ej.job_id 
    AND ej.employee_id = e.id
    AND ej.effective_date = (SELECT MAX(ej2.effective_date)
                             FROM employee_jobs ej2
                             WHERE ej2.employee_id = ej.employee_id 
                               AND ej2.effective_date <= CURRENT_DATE)
    AND COALESCE(e.termination_date, CURRENT_DATE+1) < CURRENT_DATE
  GROUP BY d.id ) dept_terms, 
  (SELECT COUNT(*) term_count
   FROM employees e
   WHERE COALESCE(e.termination_date, CURRENT_DATE+1) < CURRENT_DATE) total_terms
WHERE dept.id = dept_terms.dept_id
  AND dept.location_id = loc.id;

-- PART 3 Question 3c
SELECT COUNT(*) term_count, j.code, j.name job_title
FROM
  departments d, 
  employees e,
  employee_jobs ej, 
  jobs j, 
  locations l
WHERE d.id = j.department_id 
  AND d.location_id = l.id
  AND j.id = ej.job_id 
  AND ej.employee_id = e.id
  AND ej.effective_date = (SELECT MAX(ej2.effective_date)
                           FROM employee_jobs ej2
                           WHERE ej2.employee_id = ej.employee_id 
                             AND ej2.effective_date <= CURRENT_DATE)
  AND COALESCE(e.termination_date, CURRENT_DATE+1) < CURRENT_DATE
GROUP BY j.code, j.name
ORDER BY term_count DESC;
