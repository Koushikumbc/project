CREATE OR REPLACE FUNCTION fallout_report(as_of_date date ,todays_date date, dates_through date, include_all boolean DEFAULT true) RETURNS TABLE(
    debug text,
    project_id integer,
    status text,
    follow_up integer
)

BEGIN 
    RETURN QUERY
    --creating connection between projects 
    WITH projects_relation AS(
        SELECT a.preceding_project_id AS project_id, a.project_id AS follow_up,b.is_approved,b.is_viable,b.date_start,b.date_end,b.date_created
        FROM projects a 
        INNER JOIN projects b 
        ON a.preceding_project_id = b.project_id
    )

    -- creating column with status which in future can be used to link projects to reports
    WITH temp AS(
        SELECT project_id,
        CASE 
        WHEN is_approved=true THEN 'Approved_Project',
        WHEN is_approved=false THEN
            CASE WHEN date_start > dates_through THEN 'Out-Of-Range',
            
             WHEN date_start > todays_date THEN 'Future Project',

             WHEN date_created NOT BETWEEN as_of_date AND dates_through THEN 'Out-Of-Bounds',

             WHEN project_id NOT IN (SELECT project_id FROM projects_relation) THEN 'Not Sold',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select follow_up from projects_relation a INNER JOIN projects b on a.follow_up = b.projects where b.date_start > todays_date) THEN 'SOLD',

             WHEN (date_start BETWEEN as_of_date AND dates_through) AND (date_end BETWEEN as_of_date AND dates_through) AND (date_end > todays_date) THEN 'Current Project',

             END 'Unexpected Outcome'

        END 'Unexpected Outcome' AS status




    ) 
    SELECT p.preceding_project_id AS project_id, p.is_approved AS status, p.project_id AS follow_up
    FROM projects p
    where p.preceding_project_id IS NOT NULL AND 