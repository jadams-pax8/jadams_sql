select
	day,
	clicks,
	impressions,
	costs,
	case 
		when platform like 'Linked' then 'LinkedIn'
		else platform
	end as platform,
	case
		when ad_campaign like 'EMEA Security Campaign%' then 'EMEA Security Campaign'
		when ad_campaign like 'Global Brand%' then 'Global Brand Campaign'
		when ad_campaign like 'Why Pax8 %' then 'Why Pax8'
		else ad_campaign
	end as ad_campaign,
	conversions,
	ad_id,
	case 
		when region like 'NORDIC' then 'NORDICS'
		else region
	end as region,
	audience_name,
	case 
	 when conversion_schedule_a_call is null then 0
	 else conversion_schedule_a_call
	end as conversion_schedule_a_call,
	case 
	 when conversion_schedule_a_demo is null then 0
	 else conversion_schedule_a_demo
	end as conversion_schedule_a_demo,
	case 
	 when conversion_partner_signup is null then 0
	 else conversion_partner_signup
	end as conversion_partner_signup, 
	case 
	 when conversion_peer_group is null then 0
	 else conversion_peer_group
	end as conversion_peer_group, 
	case 
	 when conversion_event_registration is null then 0
	 else conversion_event_registration
	end as conversion_event_registration,
	case 
	 when conversion_guide_download is null then 0
	 else conversion_guide_download
	end as conversion_guide_download
from (
select
	adverity.google_creative.day as day,
	adverity.google_creative.clicks as clicks,
	adverity.google_creative.impressions as impressions,
	round(adverity.google_creative.costs,2) as costs, 
	adverity.google_creative.platform as platform,
	adverity.google_creative.ad_campaign as ad_campaign,
	adverity.google_creative.conversions as conversions,
	adverity.google_creative.ad_id as ad_id,
	adverity.google_creative.region as region,
	adverity.google_creative.audience_name as audience_name,
    sum(adverity.google_conversions.conversion_schedule_a_call) as conversion_schedule_a_call,
    sum(adverity.google_conversions.conversion_schedule_a_demo) as conversion_schedule_a_demo,
	sum(adverity.google_conversions.conversion_partner_signup) as conversion_partner_signup, 
	sum(adverity.google_conversions.conversion_peer_group) as conversion_peer_group, 
	sum(adverity.google_conversions.conversion_event_registration) as conversion_event_registration, 
	sum(adverity.google_conversions.conversion_guide_download) as conversion_guide_download
from 
	adverity.google_creative 
left join 
	adverity.google_conversions  using (ad_id,day)
group by 1,2,3,4,5,6,7,8,9,10

union all

select
	adverity.linkedin_creative.day as day,
	adverity.linkedin_creative.clicks as clicks,
	adverity.linkedin_creative.impressions as impressions,
	round(adverity.linkedin_creative.costs,2) as costs, 
	adverity.linkedin_creative.platform as platform,
	adverity.linkedin_creative.ad_campaign as ad_campaign,
	adverity.linkedin_creative.conversions as conversions,
	adverity.linkedin_creative.ad_id as ad_id,
	adverity.linkedin_creative.region as region,
	adverity.linkedin_creative.audience_name as audience_name,
	sum(adverity.linkedin_conversions.conversion_schedule_a_call) as conversion_schedule_a_call, 
	sum(adverity.linkedin_conversions.conversion_schedule_a_demo) as schedule_a_demo, 
	sum(adverity.linkedin_conversions.conversion_partner_signup) as conversion_partner_signup, 
	sum(adverity.linkedin_conversions.conversion_peer_group) as conversion_peer_group, 
	sum(adverity.linkedin_conversions.conversion_event_registration) as conversion_event_registration, 
	sum(adverity.linkedin_conversions.conversion_guide_download) as conversion_guide_download
from 
	adverity.linkedin_creative
left join 
	adverity.linkedin_conversions using (ad_id,day)
group by 1,2,3,4,5,6,7,8,9,10

union all 
	
select
	day,
	clicks,
	impressions,
	round(costs,2) as costs,
	platform,
	ad_campaign,
	conversions,
	ad_id,
	region,
	audience_name,
    conversion_schedule_a_call, 
	conversion_schedule_a_demo,
	conversion_partner_signup, 
	conversion_peer_group,
	conversion_event_registration,
	conversion_guide_download
from
	adverity.mailgun_rollworks
	
union all 
	
select
	day,
	clicks,
	impressions,
	round(costs,2) as costs,
	platform,
	ad_campaign,
	conversions,
	ad_id,
	region,
	audience_name,
    null as conversion_schedule_a_call, 
	null as conversion_schedule_a_demo,
	null as conversion_partner_signup, 
	null as conversion_peer_group,
	null as conversion_event_registration,
	null as conversion_guide_download
from
	adverity.reddit_ads

union all	

select
	day,
	clicks,
	impressions,
	round(costs,2) as costs,
	platform,
	ad_campaign,
	conversions,
	ad_id,
	region,
	audience_name,
    cast(conversion_schedule_a_call AS float), 
	cast(conversion_schedule_a_demo as float),
	cast(conversion_partner_signup as float), 
	cast(conversion_peer_group as float),
	cast(conversion_event_registration as float),
	cast(conversion_guide_download as float)
from
	adverity.facebook_ads
) order by day desc