with
 
currency_converter as ( 
select *
from 
	erdw.currency_exchange_rate	
where
	exchange_rate_base_currency_code = 'CAD' and exchange_rate_source_currency_code = 'USD'
order by effective_date desc	
limit 1
),
 
main_frame as (
select
distinct
par.partner_id,
par.partner_name,
dcu.customer_name, 
dve.vendor_name,
--prod.product_name, -- 
prod.product_id,
--ftr.transaction_monthly_created_date, -- 
ftr.transaction_monthly_charge_created_date, -- 
--sub.subscription_status,
--ftr.transaction_monthly_sku, --
sub.created_date,
--sub.subscription_id, -- 
sub.subscription_start_date,
--sub.subscription_end_date, -- 
--ftr.transaction_monthly_currency_key,
--fcm.fact_campaign_member_modified_date,
ftr.transaction_monthly_quantity,
(case when ftr.transaction_monthly_currency_key = '327' then ftr.transaction_monthly_gmrr/cc.exchange_rate_conversion_rate else ftr.transaction_monthly_gmrr end) as transaction_monthly_gmrr,
(case when ftr.transaction_monthly_currency_key = '327' then ftr.transaction_monthly_nmrr/cc.exchange_rate_conversion_rate else ftr.transaction_monthly_nmrr end) as transaction_monthly_nmrr
from
	esdw.fact_transaction_monthly ftr
left join
	esdw.dim_product prod ON ftr.transaction_monthly_product_key = prod.product_key
left join
	esdw.dim_partner par ON ftr.transaction_monthly_partner_key = par.partner_key
left join
	esdw.dim_customer dcu ON ftr.transaction_monthly_customer_key = dcu.customer_key
left join
	esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
left join
	esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
left join
	currency_converter cc ON ftr.transaction_monthly_currency_key = cc.exchange_rate_base_currency_key
left join
	esdw.fact_campaign_member fcm on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
-- left join 
-- 	esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
where
	sub.subscription_status in ('Active','Converted')
and
	transaction_monthly_is_voided IS FALSE
and 
	dve.is_current IS TRUE
and
	dve.is_deleted IS FALSE
and 
	dve.vendor_is_custom_vendor IS NOT TRUE
and 
	par.is_current IS TRUE
and 
	par.is_deleted IS FALSE
and 
	par.partner_is_test IS FALSE
),
 
b1 as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		product_id = '9696'
),
 
b2 as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		product_id = '3649'
),
 
b3 as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		product_id = '3648'
),
 
b4 as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		product_id = '3647'
),
 
b5 as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		product_id = '9697'
),
 
todyl as (
	select
	distinct 
		partner_id 
	from 
		esdw.partner_master 
	where 
		vendor_name = 'Todyl'
),
 
-- ARREARS --
 
nov_2022_cyberCNS_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2022 Nov Cyber CNS Send'
	and
	 	fcm.fact_campaign_member_modified_date >= '2022-11-03'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2022-11-03'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2022-11-03'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
dec_2022_AWS_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2022 Dec AWS Sales Play'
	and
	 	fcm.fact_campaign_member_modified_date >= '2022-12-06'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2022-12-06'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2022-12-06'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
dec_2022_bitdefender_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = ('EB 2022 Dec Managed Security MDR Bitdefender Sales Play')
	and
	 	fcm.fact_campaign_member_modified_date >= '2022-12-13'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2022-12-13'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2022-12-13'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
jan_2023_acronis_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2023 Acronis Sales Play'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-01-31'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-01-31'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-01-31'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
 
feb_2023_MDRXDR_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name in ('EB 2023 Feb XDR MDR Sales Play Email 1','EB 2023 Feb XDR MDR Sales Play Email 2')
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-02-23'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-02-23'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-02-23'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
march_2023_DNS_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name in ('PC 2023 Mar DNS Filter Sales Play Parent', 'EB 2023 Mar DNS Filter Sales Play Email 1', 'EB 2023 Mar DNS Filter Sales Play Email 2', 'EB 2023 Mar DNS Filter Sales Play Email 3')
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-03-20'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-03-20'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-03-20'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
may_2023_S1_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2023 May S1 Vigilance Ranger Upsell Sales Play'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-05-09'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-05-09'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-05-09'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
july_2023_dropsuite_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
 		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
-- --     left join
-- -- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB-2023-07-Sales Play Dropsuite Backup-NA-1295'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-07-20'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-07-20'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-07-20'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
aug_2023_password_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB-2023-08-Password Manager Sales Play-NA-1392'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-08-17'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-08-17'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-08-17'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
sept_2023_email_pt2_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB-2023-09-Security Sales Play-NA-1613'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-09-29'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-09-29'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-09-29'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
oct_2023_S1_ranger_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB-2023-10-S1 Sales Play Q4-NA-1657'
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-10-13'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-10-13'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-10-13'
	and
	    ftr.transaction_monthly_gmrr > '0'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
--- ENTITLEMENT ----
 
sept_2022_dropsuite_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2022-09-22 DropSuite Sales Play'
	and
	 	fcm.fact_campaign_member_modified_date >= '2022-09-22'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2022-09-22'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2022-09-22'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
nov_2022_Quickbooks_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name = 'EB 2022 Nov Quickbooks Sales Play'
	and
	 	fcm.fact_campaign_member_modified_date >= '2022-12-29'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2022-12-29'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2022-12-29'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1)),
 
Jan_2023_Microsoft_date as (
 
select
		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
		avg(datediff(days,min_sub,min_order)) as transaction_delta
from (select 
		par.partner_id,
		--dc.campaign_name,
	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
	   min(sub.created_date) as min_sub,
	   min(ftr.transaction_monthly_created_date) as min_order
    from 
        esdw.fact_campaign_member fcm
	left join 
		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
	left join 
		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
    left join
		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
--     left join
-- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
    left join
	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
	where 
		dc.campaign_name in ('EB 2023 Jan Microsoft Sales Play (No Gift Card)','EB 2023 Jan Microsoft Sales Play (Gift Card)')
	and
	 	fcm.fact_campaign_member_modified_date >= '2023-01-26'
	and
	    sub.created_date >= fcm.fact_campaign_member_modified_date 
	and
	    sub.created_date >= '2023-01-26'
	and
	    ftr.transaction_monthly_created_date >= sub.created_date
	and
	    ftr.transaction_monthly_created_date >= '2023-01-26'
	and   
	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
group by 1))
 
-- July_2023_DropSuite_date as (
--  
-- select
-- 		avg(datediff(days,min_touch,min_sub)) as engagement_delta,
-- 		avg(datediff(days,min_sub,min_order)) as transaction_delta
-- from (select 
-- 		par.partner_id,
-- 		--dc.campaign_name,
-- 	   min(fcm.fact_campaign_member_modified_date) as min_touch, -- look into this -- go throught logic above ^^^
-- 	   min(sub.created_date) as min_sub,
-- 	   min(ftr.transaction_monthly_created_date) as min_order
--     from 
--         esdw.fact_campaign_member fcm
-- 	left join 
-- 		esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id
-- 	left join 
-- 		esdw.dim_partner par on fcm.fact_campaign_member_account_id = par.partner_sf_account_id 
--     left join
-- 		esdw.fact_transaction_monthly ftr on ftr.transaction_monthly_partner_key = par.partner_key
-- --     left join
-- -- 		esdw.dim_vendor dve ON ftr.transaction_monthly_vendor_key = dve.vendor_key
--     left join
-- 	    esdw.dim_subscription sub ON ftr.transaction_monthly_subscription_key = sub.subscription_key
-- 	where 
-- 		dc.campaign_name = 'EB-2023-07-Sales Play Dropsuite Backup-NA-1295'
-- 	and
-- 	 	fcm.fact_campaign_member_modified_date >= '2023-07-20'
-- 	and
-- 	    sub.created_date >= fcm.fact_campaign_member_modified_date 
-- 	and
-- 	    sub.created_date >= '2023-07-20'
-- 	and
-- 	    ftr.transaction_monthly_created_date >= sub.created_date
-- 	and
-- 	    ftr.transaction_monthly_created_date >= '2023-07-20'
-- 	and   
-- 	    fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
-- group by 1))
-- 	
	select 
		month::date as month,
		vendor_name as sales_play,
		partners,
		customers,
		round(gmrr,2) as gmrr, 
		round(nmrr,2) as nmrr,
		round(quantity,2) as quantity,
		billing_type,
		contacted,
		(case when contacted is not null then (partners/contacted)::float else null end) as engagement_rate,
		engagement_delta,
		transaction_delta
	from
	(
	-- EB 2022-09-22 DropSuite Sales Play --
	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2022_Sept_DropSuite' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
		(select engagement_delta from sept_2022_dropsuite_date) as engagement_delta,
		(select transaction_delta from sept_2022_dropsuite_date) as transaction_delta,
		null as contacted,
		'entitlement' as billing_type
	from
		main_frame 
	where
		vendor_name = 'Dropsuite'
	and
		subscription_start_date >= '2022-09-22' 
	-- add filtering for other dates 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
			esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name = 'EB 2022-09-22 DropSuite Sales Play'
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
-- 		and 
-- 			fact_campaign_member_status in ('Opened','Clicked')
	 ) group by 1,2
 
union all
 
-- EB 2022 Nov Cyber CNS Send -- rebranded to 'ConnectSecure'
 
	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2022_Nov_CyberCNS' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
		(select engagement_delta from nov_2022_cyberCNS_date) as engagement_delta,
		(select transaction_delta from nov_2022_cyberCNS_date) as transaction_delta,
		null as contacted,
		'arrears' as billing_type
	from
		main_frame 
	where
		product_id in ('6984', '6650')
	and
		subscription_start_date >= '2022-11-03' 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name = 'EB 2022 Nov Cyber CNS Send'
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
		 ) group by 1,2

union all

-- EB 2022 Dec AWS Sales Play --
 
	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2022_Dec_AWS' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
		(select engagement_delta from dec_2022_AWS_date) as engagement_delta,
		(select transaction_delta from dec_2022_AWS_date) as transaction_delta,
		null as contacted,
		'arrears' as billing_type
	from
		main_frame 
	where
		vendor_name = 'AWS'
	and
		subscription_start_date >= '2022-12-06' -- manually input for sales play 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name = 'EB 2022 Dec AWS Sales Play'
		and
			fact_campaign_member_status in ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
		 ) group by 1,2
union all
-- EB 2022 Dec Managed Security MDR Bitdefender Sales Play -- 
	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2022_Dec_MDR_Bitdefender' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
		(select engagement_delta from dec_2022_bitdefender_date) as engagement_delta,
		(select transaction_delta from dec_2022_bitdefender_date) as transaction_delta,
		null as contacted,
		'arrears' as billing_type
	from
		main_frame 
	where
		(subscription_start_date >= '2022-12-13' 
	and
		partner_id in (select partner_id from b1) 
	and
		partner_id in (select partner_id from b2) 
	and
		partner_id in (select partner_id from b3) 
	and
		partner_id in (select partner_id from b4) 
	and
		partner_id in (select partner_id from b5) 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name in ('EB 2022 Dec Managed Security MDR Bitdefender Sales Play')
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
		 ))
	or 
		(subscription_start_date >= '2022-12-13' 
	and
		partner_id in (select partner_id from todyl) 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name in ('EB 2022 Dec Managed Security MDR Bitdefender Sales Play')
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
)) group by 1,2
 
 
union all
 
-- EB 2022 Nov Quickbooks Sales Play -- 
	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2022_Nov_Quickbooks' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
		(select engagement_delta from nov_2022_Quickbooks_date) as engagement_delta,
		(select transaction_delta from nov_2022_Quickbooks_date) as transaction_delta,
		null as contacted,
		'entitlement' as billing_type
	from
		main_frame 
	where
		product_id in ('2409','2358','10815')--'Dropsuite','NetApp') -- what about CloudJumper, Dropsuite, Intuit, NetApp
	and
		subscription_start_date >= '2022-12-29' 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name = 'EB 2022 Nov Quickbooks Sales Play'
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
		 ) group by 1,2
-- 		 
union all
	
--  -- EB 2023 Jan Microsoft Sales Play (Gift Card) and EB 2023 Jan Microsoft Sales Play (No Gift Card) -- 
  	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		'2023_Jan_Microsoft' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from Jan_2023_Microsoft_date) as engagement_delta,
		(select transaction_delta from Jan_2023_Microsoft_date) as transaction_delta,
 		null as contacted,
 		'entitlement' as billing_type 
 	from
 		main_frame 
 	where
 		vendor_name = 'Microsoft'
 	and
 		subscription_start_date >= '2023-01-26' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name in ('EB 2023 Jan Microsoft Sales Play (No Gift Card)','EB 2023 Jan Microsoft Sales Play (Gift Card)')
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 
 union all
 
-- -- EB 2023 Acronis Sales Play --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		'2023_Jan_Acronis' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from jan_2023_acronis_date) as engagement_delta,
		(select transaction_delta from jan_2023_acronis_date) as transaction_delta,
 		(1836)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 		vendor_name = 'Acronis'
 	and
 		subscription_start_date >= '2023-01-31' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name = 'EB 2023 Acronis Sales Play'
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 		 
  union all 
 	-- 2023.02 XDR/MDR Sales Play -- 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		'2023_FEB_MDR_Bitdefender' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from feb_2023_MDRXDR_date) as engagement_delta,
		(select transaction_delta from feb_2023_MDRXDR_date) as transaction_delta,
 		(6081)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 		(subscription_start_date >= '2023-02-23' 
 	and
 		partner_id in (select partner_id from b1) 
 	and
 		partner_id in (select partner_id from b2) 
 	and
 		partner_id in (select partner_id from b3) 
 	and
 		partner_id in (select partner_id from b4) 
 	and
 		partner_id in (select partner_id from b5) 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name in ('EB 2023 Feb XDR MDR Sales Play Email 1','EB 2023 Feb XDR MDR Sales Play Email 2')
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ))
 	or 
 		(subscription_start_date >= '2023-02-23' 
 	and
 		partner_id in (select partner_id from todyl) 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name in ('EB 2023 Feb XDR MDR Sales Play Email 1','EB 2023 Feb XDR MDR Sales Play Email 2')
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 )) group by 1,2
	
union all
 
 -- PC 2023 Mar DNS Filter Sales Play Parent --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		'2023_Mar_DNSFilter' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from march_2023_DNS_date) as engagement_delta,
		(select transaction_delta from march_2023_DNS_date) as transaction_delta,
 		(6301)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 		vendor_name = 'DNSFilter'
 	and
 		subscription_start_date >= '2023-03-20' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name in ('PC 2023 Mar DNS Filter Sales Play Parent', 'EB 2023 Mar DNS Filter Sales Play Email 1', 'EB 2023 Mar DNS Filter Sales Play Email 2', 'EB 2023 Mar DNS Filter Sales Play Email 3')
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 		 
 		 
 		 
 union all
 
 -- EB 2023 May S1 Vigilance Ranger Upsell Sales Play --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		 '2023_May_S1_Vigilance' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from may_2023_S1_date) as engagement_delta,
		(select transaction_delta from may_2023_S1_date) as transaction_delta,
 		(134)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 		product_id in ('7574','6387','9060')
 	and
 		subscription_start_date >= '2023-05-09' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name = 'EB 2023 May S1 Vigilance Ranger Upsell Sales Play'
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 		 
 		 
 		 
 union all
 
 -- EB-2023-07-Sales Play Dropsuite Backup-NA-1295 --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		 '2023_July_DropSuite' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from July_2023_DropSuite_date) as engagement_delta,
		(select transaction_delta from July_2023_DropSuite_date) as transaction_delta,
 		(2721)::float as contacted,
 		'entitlement' as billing_type
 	from
 		main_frame 
 	where
 		vendor_name = 'Dropsuite'
 	and
 		subscription_start_date >= '2023-07-20' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name = 'EB-2023-07-Sales Play Dropsuite Backup-NA-1295'
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 		 
 		 
  union all
 
 -- EB-2023-08-Password Manager Sales Play-NA-1392 --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		 '2023_August_Password_Manager' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from aug_2023_password_date) as engagement_delta,
		(select transaction_delta from aug_2023_password_date) as transaction_delta,
 		(932)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 		vendor_name in ('N-able Passportal', 'Keeper Security', 'LastPass')
 	and
 		subscription_start_date >= '2023-08-17' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name = 'EB-2023-08-Password Manager Sales Play-NA-1392'
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2
 		 
   union all 
-- -- EB-2023-09-Security Sales Play-NA-1613 --

 	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		 '2023_Sept_Email_Security_pt2' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from sept_2023_email_pt2_date) as engagement_delta,
		(select transaction_delta from sept_2023_email_pt2_date) as transaction_delta,
		(238)::float as contacted,
		'arrears' as billing_type
	from
		main_frame 
	where
		vendor_name in ('Ironscales','TitanHQ')
	or
	    product_id = ('3650')
	and
		subscription_start_date >= '2023-09-29' -- manually input for sales play 
	and
		partner_id 
	in 
	(select 
			distinct
			dp.partner_id 
		from 
				esdw.fact_campaign_member fcm 
		left join 
			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
		left join 
			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
		where 
			dc.campaign_name = 'EB-2023-09-Security Sales Play-NA-1613'
		and
			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
		and 
			dp.partner_id is not null 
		and 
			dp.partner_id != '1'
		 ) group by 1,2
 
 union all 

 -- EB-2023-10-S1 Sales Play Q4-NA-1657 --
 
 	select 
 		date_trunc('month',transaction_monthly_charge_created_date) as month,
 		'2023_Oct_S1_Ranger_pt2' as vendor_name, 
 		count(distinct partner_id) as partners,
 		count(distinct customer_name) as customers,
 		sum(transaction_monthly_gmrr) as gmrr,
 		sum(transaction_monthly_nmrr) as nmrr, 
 		sum(transaction_monthly_quantity) as quantity,
 		(select engagement_delta from oct_2023_S1_ranger_date) as engagement_delta,
		(select transaction_delta from oct_2023_S1_ranger_date) as transaction_delta,
 		(1712)::float as contacted,
 		'arrears' as billing_type
 	from
 		main_frame 
 	where
 	    product_id in ('7574','6387','9060')
 	and
 		subscription_start_date >= '2023-10-13' -- manually input for sales play 
 	and
 		partner_id 
 	in 
 	(select 
 			distinct
 			dp.partner_id 
 		from 
 				esdw.fact_campaign_member fcm 
 		left join 
 			esdw.dim_campaign dc on fcm.fact_campaign_member_campaign_id = dc.campaign_id 
 		left join 
 			esdw.dim_partner dp on fcm.fact_campaign_member_account_id = dp.partner_sf_account_id 
 		where 
 			dc.campaign_name = 'EB-2023-10-S1 Sales Play Q4-NA-1657'
 		and
 			fact_campaign_member_status in  ('Clicked','Visited Page','Scheduled a Call','Opened','Downloaded Content')
 		and 
 			dp.partner_id is not null 
 		and 
 			dp.partner_id != '1'
 		 ) group by 1,2)
 -- 		 
  where month >= '2023-10-01'
 	order by month asc