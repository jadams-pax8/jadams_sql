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
prod.product_name, -- 
prod.product_id,
ftr.transaction_monthly_created_date, -- 
ftr.transaction_monthly_charge_created_date, -- 
sub.subscription_status,
ftr.transaction_monthly_sku, --
sub.subscription_id, -- 
sub.subscription_start_date,
sub.subscription_end_date, -- 
ftr.transaction_monthly_currency_key, 
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
)
	
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
		(case when contacted is not null then (partners/contacted)::float else null end) as engagement_rate
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
		--(6600)::float as contacted
		null as contacted,
		'entitlement' as billing_type
	from
		main_frame 
	where
		vendor_name = 'Dropsuite'
	and
		subscription_start_date >= '2022-09-22' 
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
-- 		 
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
		 
union all
		 
 -- EB 2023 Jan Microsoft Sales Play (Gift Card) and EB 2023 Jan Microsoft Sales Play (No Gift Card) -- 
 
 	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2023_Jan_Microsoft' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
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

-- EB 2023 Acronis Sales Play -- 

	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		'2023_Jan_Acronis' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
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
		(subscription_start_date >= '2023-02-22' 
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
		 
-- EB-2023-09-Security Sales Play-NA-1613 --

	select 
		date_trunc('month',transaction_monthly_charge_created_date) as month,
		 '2023_Sept_Email_Security_pt2' as vendor_name, 
		count(distinct partner_id) as partners,
		count(distinct customer_name) as customers,
		sum(transaction_monthly_gmrr) as gmrr,
		sum(transaction_monthly_nmrr) as nmrr, 
		sum(transaction_monthly_quantity) as quantity,
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
