{{
    config(materialized='table_definition'
        ,schema='PUBLIC'
        ,enabled=true
    )
}}

CREATE TABLE "{{ database }}"."PUBLIC"."TEST" (
	STREET_NUMBER   NUMBER(4),
	LINE1 VARCHAR(200),
	LINE2 VARCHAR(200),
	CITY VARCHAR(200),
	STATE VARCHAR(200),
	ZIPCODE VARCHAR(100),
	COUNTRY VARCHAR(100)
)
