-- Solution for 2017 Term 1 CMPT355 Assignment 3
-- Author: Lujie Duan

-- copy in psql to load data files



\copy load_locations FROM 'assgn3-locationFile.csv' CSV HEADER;

\copy load_departments FROM 'assgn3-departmentFile.csv' CSV HEADER;

-- This need to be the one that has been corrected 
\copy load_employee_data FROM 'assgn3-employeeFileUTF8.csv' CSV HEADER;

\copy load_jobs FROM 'assgn3-jobFile.csv' CSV HEADER;


