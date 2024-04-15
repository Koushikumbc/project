CREATE OR REPLACE FUNCTION fallout_report(as_of_date date ,todays_date date, dates_through date, include_all boolean DEFAULT true) RETURNS TABLE(
    debug text,
    project_id integer,
    status text,
    follow_up integer
)

BEGIN 
    RETURN QUERY
    SELECT 