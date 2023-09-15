select
	fcm.created_date, 
	fcm.fact_campaign_member_status,
	-- dc.campaign_name,
	fcm.fact_campaign_member_member_type,
case
	when fcm.fact_campaign_member_member_type like 'Contact' then dcon.contact_first_name
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_first_name
end as first_name,
case
	when fcm.fact_campaign_member_member_type like 'Contact' then dcon.contact_last_name
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_last_name
end as last_name,
concat(concat(first_name, ' '), last_name) AS full_name,
case
	when fcm.fact_campaign_member_member_type like 'Contact' then dcon.contact_country
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_country
end as country,
case
	when fcm.fact_campaign_member_member_type like 'Contact' then dp.partner_name
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_company_name
end as company_name,
case
	when campaign_name like 'OP-2023-Academy Schedule a Call-GLBL-1053' then 'Academy Schedule a Call'
	when campaign_name like 'OP-2023-Channel Events Schedule a Call-GLBL-1054' then 'Channel Events Schedule a Call'
	when campaign_name like 'OP-2023-MSP Referral-GLBL-1056' then 'MSP Referral'
	when campaign_name like 'OP-2023-Peer Group Requested-GLBL-1058' then 'Peer Group Requested'
	when campaign_name like 'OP-2023-Schedule a Call-GLBL-1052' then 'Schedule a Call'
	when campaign_name like 'OP-2023-Schedule a Demo-GLBL-1055' then 'Schedule a Demo'
	else campaign_name
end as form_name,
	fcm.fact_campaign_member_key as member_key,
	fcm.fact_campaign_member_id as member_id,
	fcm.fact_campaign_member_contact_key as contact_key,
	fcm.fact_campaign_member_contact_id as contact_id,
	fcm.fact_campaign_member_campaign_key as campaign_key,
	fcm.fact_campaign_member_campaign_id as campaign_id,
	fcm.fact_campaign_member_account_id as partner_sf_account_id
from 
	esdw.fact_campaign_member fcm
left join 
	esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_key = dc.campaign_key
left join 
	esdw.dim_lead dl on fcm.fact_campaign_member_lead_id = dl.lead_id
left join 
	esdw.dim_contact dcon on fcm.fact_campaign_member_contact_id = dcon.contact_id
left join 
	esdw.dim_partner dp on dp.partner_sf_account_id = fcm.fact_campaign_member_account_id
where 
	campaign_key like '14113' or 
	campaign_key like '14081' or 
	campaign_key like '14113' or
	campaign_key like '14065' or
	campaign_key like '14097' or 
	campaign_key like '15849' or 
	campaign_key like '15865'