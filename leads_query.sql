select 
	lead_key,
	created_date,
	lead_created_date,
	modified_date,
	lead_modified_date,
	lead_last_activity_date,
	effective_date,
	lead_id,
	lead_status,
	lead_account_type,
	lead_is_converted,
    is_current,
	lead_is_deleted,
	CASE
       WHEN lead_source ilike 'AI Informed%' or
		     lead_source like 'AI List%' or
		     lead_source like 'List Pr%' or
		     lead_source like 'AI Provider%' or
		     lead_source ilike '%zoominfo%' or
             lead_source ilike '%zoom_info%' or
		     lead_source ilike '%smarte%' or
		     lead_source ilike '%list-%' or
             lead_source ilike '%=list%' or
             lead_source ilike '%leadlist%' or
             lead_source ilike '%partnerlist%' or
             lead_source ilike '%Infrastructure%' or
             lead_source ilike '%partnerprospects%' or
             lead_source ilike '%partnerlocator%' or
		     lead_source ilike '%everstring%' 
        then 'Data Provider'
        WHEN lead_source ilike '%partner sign up%' or
             lead_source ilike '%patner sign up%' or
             lead_source ilike '%partner signup%' or
             lead_source ilike '%partner_signup%' or  
             lead_source ilike '%partnersignup%' or 
             lead_source like 'Drift' or
             lead_source like 'Organic' or
             lead_source ilike '%Demo Request%' or 
             lead_source ilike '%International Form%' or 
             lead_source ilike '%Website%' or 
             lead_source like '%Contact Us%' 
        then 'Organic'
        WHEN lead_source ilike '%linkedin%' or
             lead_source ilike '%google%' or
             lead_source ilike '%direct_mail%' or
             lead_source like 'Digital Advertising' or
             lead_source ilike '%demand works%' or
             lead_source ilike '%demandworks%' or 
             lead_source ilike '%content syndication%' 
        then 'Demand Generation'
        ELSE 'Other'
    END AS lead_source,
	lead_company_name,
	concat(concat(lead_first_name, ' '), lead_last_name) AS lead_full_name,
	lead_state,
	lead_country,
	lead_email_address,
	lead_domain,
	lead_first_utm_source,
	lead_last_utm_source,
	lead_first_utm_campaign,
	lead_last_utm_campaign
from esdw.dim_lead dl 
	where lead_is_converted = FALSE