-- Pull members of a specific campaign
with campaign_info as (
    select
        campaign_name,
        campaign_id,
        campaign_type,
        campaign_created_date
    from esdw.dim_campaign
-- Filter which email campaign you want to analyze
    where campaign_id like '7012L000000uCKHQA2' --EB-2023-08-AWS Brand Campaign EM1-NA-1425
),

contact_ids AS (
    select
        dc.campaign_name as campaign_name,
        dc.campaign_id,
        dc.campaign_type as campaign_type,
        dc.campaign_created_date as campaign_created_date,
        fcm.fact_campaign_member_contact_id as contact_id,
        fcm.fact_campaign_member_lead_id as lead_id,
        fcm.fact_campaign_member_status as member_status,
        fcm.fact_campaign_member_member_type as member_type,
        fcm.fact_campaign_member_account_id as account_id
    from campaign_info dc
    left join 
        esdw.fact_campaign_member fcm on dc.campaign_id = fcm.fact_campaign_member_campaign_id
),

contact_info AS (
    select 
        ci.campaign_name as campaign_name,
        ci.campaign_id,
        ci.campaign_type as campaign_type,
        ci.campaign_created_date as campaign_created_date,
        ci.member_status as member_status,
        ci.member_type as member_type,
        case
         when ci.member_type like 'Contact' then dcon.contact_first_name
	     when ci.member_type like 'Lead' then dl.lead_first_name
        end as first_name,
        case
	     when ci.member_type like 'Contact' then dcon.contact_last_name
	     when ci.member_type like 'Lead' then dl.lead_last_name
        end as last_name,
        concat(concat(first_name, ' '), last_name) AS full_name,
        case
	     when ci.member_type like 'Contact' then dcon.contact_email
	     when ci.member_type like 'Lead' then dl.lead_email_address
        end as email_address,
        case
	     when ci.member_type like 'Contact' then dcon.contact_country
	     when ci.member_type like 'Lead' then dl.lead_country
        end as country,
        case
	     when ci.member_type like 'Contact' then dp.partner_name
	     when ci.member_type like 'Lead' then dl.lead_company_name
        end as company_name
    from contact_ids ci
    left join 
	    esdw.dim_lead dl on ci.lead_id = dl.lead_id
    left join 
	    esdw.dim_contact dcon on ci.contact_id = dcon.contact_id
    left join 
	    esdw.dim_partner dp on ci.account_id = dp.partner_sf_account_id
)

select 
    campaign_name,
    campaign_type,
    campaign_created_date,
    member_status,
    full_name,
    email_address,
    country,
    company_name
from contact_info