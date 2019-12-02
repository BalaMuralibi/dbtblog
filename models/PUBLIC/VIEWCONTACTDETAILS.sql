{{
    config(materialized='view_definition'               
        ,schema ='STAGING'        
    )
}}

create or replace view "{{ database }}"."{{ schema }}"."viewcontactdetails"
as 
SELECT *
FROM "STAGING"."CONTACTDETAILS" 
