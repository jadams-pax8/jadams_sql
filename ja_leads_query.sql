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
        WHEN lead_source ilike 'AI Informed%' or lead_source like 'AI List%' or lead_source like 'AI Provider%' then 'AI Informed Data Provider'
        WHEN lead_source like '%Abandoned%' then 'Abandoned Partner Sign Up'
        WHEN lead_source ilike '%everstring%' then 'Everstring'
        WHEN lead_source ilike '%smarte%' then 'Smarte'
        WHEN lead_source ilike '%Zoominfo%' or lead_source ilike '%zoom_info%' then 'Zoominfo'
        WHEN lead_source ilike '%partner sign up%' or lead_source ilike '%partnersignup%' then 'Partner Sign Up'
        WHEN lead_source ilike '%linkedin%' then 'LinkedIn'
        WHEN lead_source ilike '%google%' then 'Search'
        WHEN lead_source ilike '%Trade Show%' then 'Trade Show'
        WHEN lead_source ilike '%ASCII%' then 'ASCII'
        WHEN lead_source ilike '%direct_mail%' then 'Direct Mail'
        WHEN lead_source ilike '%Referral%' then 'Referral'
        WHEN lead_source ilike '%dattocon%' 
            or lead_source ilike '%Trade Show%' 
            or lead_source ilike '%XChange%' 
            or lead_source ilike '%ITNation%' 
            or lead_source ilike '%live_event%'
            or lead_source ilike '%gluex%'
            or lead_source ilike '%gluecon%'
            then 'Tradeshow'
        ELSE lead_source
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
limit 1000


-- Category ?'s
    -- is List Provider different than AI List Provider?
    -- What if source has eversting and smarte?
    -- 







-- Check for distinct values
select 
	distinct 
	CASE
        WHEN lead_source ilike 'AI Informed%' or lead_source like 'AI List%' or lead_source like 'AI Provider%' then 'Data Provider'
        WHEN lead_source like '%Abandoned%' then 'Abandoned Partner Sign Up'
        WHEN lead_source ilike '%everstring%' then 'Everstring'
        WHEN lead_source ilike '%smarte%' then 'Smarte'
        WHEN lead_source ilike '%Zoominfo%' or lead_source ilike '%zoom_info%' then 'Zoominfo'
        WHEN lead_source ilike '%partner sign up%' or lead_source ilike '%partnersignup%' then 'Partner Sign Up'
        WHEN lead_source ilike '%linkedin%' then 'LinkedIn'
        WHEN lead_source ilike '%google%' then 'Search'
        WHEN lead_source ilike '%direct_mail%' then 'Direct Mail'
        WHEN lead_source ilike '%Referral%' then 'Referral'
        WHEN lead_source ilike '%dattocon%' 
            or lead_source ilike '%Trade Show%' 
            or lead_source ilike '%XChange%' 
            or lead_source ilike '%ITNation%' 
            or lead_source ilike '%live_event%'
            or lead_source ilike '%gluex%'
            or lead_source ilike '%gluecon%'
            or lead_source ilike '%ascii%'
            then 'Tradeshow'
        ELSE lead_source,
        WHEN lead_source ilike '%sales generated%' then 'Rep Generated'
        WHEN lead_source ilike '%demand works%' or lead_source ilike '%content syndication%' then 'Content Syndication'
    END AS lead_source,
	count(*)
from esdw.dim_lead dl 
	--where lead_source like 'AI Informed%'
group by 1