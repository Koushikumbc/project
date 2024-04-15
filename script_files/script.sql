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
        SELECT a.preceding_project_id AS project_id, a.project_id AS follow_up
        FROM projects a 
        INNER JOIN projects b 
        ON a.preceding_project_id = b.project_id
    )

    -- creating column with status which in future can be used to link projects to reports
    WITH project_status AS(
        SELECT project_id,
        CASE 
        WHEN is_approved=true THEN 'Approved_Project',

        WHEN is_approved=false THEN

            CASE WHEN date_start > dates_through THEN 'Out-Of-Range',
            
             WHEN date_start > todays_date THEN 'Future Project',

             WHEN date_created NOT BETWEEN as_of_date AND dates_through THEN 'Out-Of-Bounds',

             WHEN project_id NOT IN (SELECT project_id FROM projects_relation) THEN 'Not Sold',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select project_id from projects_relation a INNER JOIN projects b on a.follow_up = b.project_id where b.date_start > todays_date) THEN 'Sold',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select project_id from projects_relation a INNER JOIN projects b on a.follow_up = b.project_id where b.date_start < todays_date AND b.date_end >todays_date) 
             THEN 'Work-In-Process',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select project_id from projects_relation a INNER JOIN projects b on a.follow_up = b.project_id WHERE b.is_approved = true) THEN 'Approved',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select project_id from projects_relation a INNER JOIN projects b on a.follow_up = b.project_id WHERE b.is_approved = false AND b.is_viable = true) THEN 'Not Approved',

             WHEN project_id IN (select project_id from projects_relation) and EXISTS(select project_id from projects_relation a INNER JOIN projects b on a.follow_up = b.project_id WHERE b.is_approved = false AND b.is_viable = false) THEN 'Not Viable',


             WHEN (date_start BETWEEN as_of_date AND dates_through) AND (date_end BETWEEN as_of_date AND dates_through) AND (date_end > todays_date) THEN 'Current Project',

             END 'Unexpected Outcome'

        END 'Unexpected Outcome' AS status

        FROM projects



    ) 
    
    SELECT b.category_description as debug, a.project_id, a.status, c.follow_up
    from project_status a
    INNER JOIN reports b
    ON a.status = b.category_name
    LEFT JOIN projects_relation
    ON a.project_id = c.project_id

    END


    select * from fallout_report('2024-01-01', '2024-06-30','2024-12-31')

    --first run the tables script to copy the flat files then run this report
    