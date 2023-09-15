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
		     lead_source ilike '%everstring%' then 'Data Provider'
        WHEN lead_source ilike '%partner sign up%' or
             lead_source ilike '%patner sign up%' or
             lead_source ilike '%partner signup%' or
             lead_source ilike '%partner_signup%' or  
             lead_source ilike '%partnersignup%' then 'Partner Sign Up'
        WHEN lead_source ilike '%linkedin%' then 'LinkedIn'
        WHEN lead_source ilike '%google%' then 'Search'
        WHEN lead_source ilike '%direct_mail%' then 'Direct Mail'
        WHEN lead_source ilike '%Referral%' then 'Referral'
        WHEN lead_source ilike '%Pax8 Event%' or
             lead_source ilike '%Webinar%' or
             lead_source ilike '%virtual_event%' or
             lead_source ilike '%=live_event%' or 
             lead_source ilike 'mission briefing%' or 
             lead_source ilike '%bootcamp%' then 'Pax8 Event'
        WHEN lead_source ilike '%dattocon%' or
             lead_source like '%Trade Show%' or
             lead_source like '%trade_show%' or
             lead_source like '%tradeshow%' or
             lead_source ilike '%xchange%' or
             lead_source ilike '%itnation%' or
             lead_source ilike '%it nation%' or
             lead_source ilike '%gluex%' or
             lead_source ilike '%gluecon%' or
             lead_source ilike '%symantec%' or
             lead_source ilike '%robinrobins%' or
             lead_source ilike '%channelpro%' or
             lead_source ilike '%ascii%' then 'Tradeshow'
        WHEN lead_source like 'Rep Generated' then 'Rep Generated'
        WHEN lead_source like 'Self Generated' then 'Self Generated'
        WHEN lead_source like 'Drift' then 'Drift'
        WHEN lead_source like 'Digital Advertising' then 'Digital Advertising'
        WHEN lead_source like 'Organic' then 'Organic'
        WHEN lead_source ilike '%Demo Request%' or
             lead_source ilike '%International Form%' or
             lead_source ilike '%Website%' or
             lead_source like '%Contact Us%' then 'Web Form'
        WHEN lead_source ilike '%sales generated%' then 'Rep Generated'
        WHEN lead_source ilike '%demand works%' or
             lead_source ilike '%demandworks%' or 
             lead_source ilike '%content syndication%' then 'Content Syndication'
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