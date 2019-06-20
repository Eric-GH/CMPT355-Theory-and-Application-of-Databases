--load data to employee_history table
CREATE OR REPLACE FUNCTION load_history()
RETURNS void AS $$
BEGIN
        --insert in to table
        INSERT INTO emp_history
        SELECT
                user,
                now(),
                'current data',
                NULL,
                e.first_name,
                e.middle_name,
                e.last_name,
                e.gender,
                e.ssn,
                e.birth_date,
                m.name, --AS marital_status,
                es.name, --AS employee_statuses,
                e.hire_date,
                e.rehire_date,
                e.termination_date,
                ts.name, --AS termination_reason,
                tt.name, --AS termination_type,
                j.code, --AS job_code,
                j.name, --AS job_title,
                ej.effective_date, --AS job_start_date,
                ej.expiry_date, --AS job_end_date,
                ej.pay_amount,
                ej.standard_hours,
                et.name, --AS employee_type,
                est.name, --AS employment_status,
                d.code --AS department_code
        FROM employees e 
         JOIN marital_statuses m ON e.marital_status_id = m.id
         JOIN employee_jobs ej ON e.id = ej.employee_id
         JOIN employee_statuses es ON ej.employee_status_id = es.id
         LEFT JOIN termination_types tt ON e.term_type_id = tt.id
         LEFT JOIN termination_reasons ts ON e.term_reason_id = ts.id
         JOIN employee_types et ON ej.employee_type_id = et.id
         LEFT JOIN employment_status_types est ON e.employment_status_id = est.id
         JOIN jobs j ON ej.job_id = j.id
         JOIN departments d ON j.department_id = d.id;
END;
$$ LANGUAGE plpgsql;

select load_history();
