select
	day,
	clicks,
	impressions,
	costs,
	platform,
	ad_campaign,
	conversions,
	ad_id,
	region,
	conversion_schedule_a_call,
	conversion_schedule_a_demo,
	conversion_partner_signup, 
	conversion_peer_group, 
	conversion_event_registration, 
	conversion_guide_download
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
-- 	(case when adverity.google_conversions.conversion_schedule_a_call <> '0' then adverity.google_conversions.conversion_schedule_a_call 
-- 	    when adverity.google_conversions.conversion_schedule_a_demo <> '0' then adverity.google_conversions.conversion_schedule_a_demo  
-- 	        when adverity.google_conversions.conversion_partner_signup <> '0' then adverity.google_conversions.conversion_partner_signup  
-- 	            when adverity.google_conversions.conversion_event_registration <> '0' then adverity.google_conversions.conversion_event_registration  
-- 	                when adverity.google_conversions.conversion_guide_download <> '0' then adverity.google_conversions.conversion_guide_download else '0' end) as column 
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
group by 1,2,3,4,5,6,7,8,9

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


group by 1,2,3,4,5,6,7,8,9
) order by day desc