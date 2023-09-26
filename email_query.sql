--
-- Too large to run
--
select 
  dc.campaign_name,
  dc.campaign_id,
  dc.campaign_type,
  dc.campaign_created_date,
  fcm.fact_campaign_member_contact_id,
  fcm.fact_campaign_member_lead_id,
  fcm.fact_campaign_member_status,
  fcm.fact_campaign_member_member_type,
  fcm.fact_campaign_member_account_id,
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
	when fcm.fact_campaign_member_member_type like 'Contact' then dcon.contact_email
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_email_address
  end as email_address,
  case
	when fcm.fact_campaign_member_member_type like 'Contact' then dcon.contact_country
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_country
  end as country,
  case
	when fcm.fact_campaign_member_member_type like 'Contact' then dp.partner_name
	when fcm.fact_campaign_member_member_type like 'Lead' then dl.lead_company_name
  end as company_name
from esdw.dim_campaign dc 
left join 
    esdw.fact_campaign_member fcm on dc.campaign_id = fcm.fact_campaign_member_campaign_id
left join 
	esdw.dim_lead dl on fcm.fact_campaign_member_lead_id = dl.lead_id
left join 
	esdw.dim_contact dcon on fcm.fact_campaign_member_contact_id = dcon.contact_id
left join 
	esdw.dim_partner dp on dp.partner_sf_account_id = fcm.fact_campaign_member_account_id
where fact_campaign_member_campaign_id like '7012L000000uCLKQA2'