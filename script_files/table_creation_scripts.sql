-- create a schema for the tables so that we can copy the data from flat files into the database tables
CREATE TABLE projects(
    project_id int Primary key,
    date_created date,
    date_start date,
    date_end date,
    is_viable boolean,
    is_approved boolean,
    preceding_project_id int
)

CREATE TABLE reports(
    category_name text,
    category_included boolean,
    category_description text,
    PRIMARY KEY(category_name,category_included,category_description)
)

-- copy command to copy data into the tables
COPY projects from '/home/adu_admin/Documents/projects-denormalized.csv' DELIMITER ',' CSV HEADER
COPY reports from '/home/adu_admin/Documents/report-categories.csv' DELIMITER ',' CSV HEADER