-- People who enrolled in specific courses
with course_info as (
	select
		e8c.e8_course_id as course_id,
		e8c.e8_course_name as course_name,
		e8c.e8_course_type as course_type,
		e8c.e8_course_category as course_category,
		e8c.e8_course_status as course_status,
		e8e.e8_enrollment_enrollment_date as enrollment_date,
		e8e.e8_enrollment_completion_date as completion_date,
		e8e.e8_enrollment_status as enrollment_status,
		e8e.e8_enrollment_user_id as user_id
	from esdw.dim_e8_course e8c
	left join 
		esdw.fact_e8_enrollment e8e on e8c.e8_course_id = e8e.e8_enrollment_course_id
--Filter for specific courses
	where course_name in ('AWS Certified Cloud Practitioner CLF-C01: Exam and Beyond')
),

user_info as (
	select
		ci.course_id as course_id,
		ci.course_name as course_name,
		ci.course_type as course_type,
		ci.course_category as course_category,
		ci.course_status as course_status,
		ci.enrollment_date as enrollment_date,
		ci.completion_date as completion_date,
		ci.enrollment_status as enrollment_status,
		e8u.e8_user_email as user_email,
		e8u.e8_user_full_name as user_name,
		e8u.e8_user_company as user_company,
		e8u.e8_user_country as user_country
	from course_info ci
	left join 
		esdw.dim_e8_users e8u on ci.user_id = e8u.e8_user_id
	where 
		(user_email not like '%@pax8.com' and 
		 user_email not like '%@paxating.com' and
		 user_email not like '%@test.com')
)

select
	course_name,
	course_type,
	course_category,
	course_status,
	enrollment_date,
	completion_date,
	enrollment_status,
	user_name,
	user_email,
	user_company,
	user_country
from user_info
limit 100