-- Users who have filled out forms that a part of the global form collection
select
	fcm.created_date,
	dc.campaign_name, 
	fcm.fact_campaign_member_status,
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
	fcm.fact_campaign_member_key as member_key,
	fcm.fact_campaign_member_id as member_id,
	fcm.fact_campaign_member_contact_key as contact_key,
	fcm.fact_campaign_member_contact_id as contact_id,
	fcm.fact_campaign_member_campaign_key as campaign_key,
	fcm.fact_campaign_member_campaign_id as campaign_id,
	fcm.fact_campaign_member_account_id as partner_sf_account_id,
	dl.lead_last_utm_campaign,
	dl.lead_last_utm_content
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
	(campaign_key like '17081' or 
	campaign_key like '17161' or
	campaign_key like '17145' or
	campaign_key like '17049' or 
	campaign_key like '17097' or
	campaign_key like '17129' or
	campaign_key like '17113' or
	campaign_key like '17065')
	and 
	(company_name not ilike 'Pax8')