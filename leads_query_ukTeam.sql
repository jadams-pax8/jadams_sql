WITH CTE_1
AS
(
SELECT 
	l.id AS leadId,
	l."name" AS leadName,
	c."name" AS contactName,
	dp.partner_id,
	dp.partner_key,
	dp.partner_name,
	dp.partner_created_date,
	dp.partner_first_transaction_date,
		CASE 
		WHEN l.leadsource LIKE '%Abandoned%' THEN 'Abandoned Partner Sign Up'
		WHEN l.leadsource LIKE '%Vendor Referral%' THEN 'Vendor Referral'
		WHEN (l.leadsource LIKE '%ASCII%' OR l.leadsource LIKE '%Datto%' OR l.leadsource LIKE '%ChannelNavigatr%' OR l.leadsource LIKE 'live event') THEN 'Trade Show'
		WHEN (l.leadsource LIKE 'rep%' OR l.leadsource LIKE 'Self%') THEN 'Rep Generated'
		WHEN (l.leadsource LIKE '%Display%' OR l.leadsource LIKE '%Search%' OR l.leadsource LIKE '%Video%' OR l.leadsource  LIKE '%Social%' ) THEN 'Digital Advertising'
		WHEN (l.leadsource LIKE '%everstring%' OR l.leadsource LIKE '%Zoominfo%' OR l.leadsource LIKE '%Smarte%' OR l.leadsource LIKE '%List Provider%' OR l.leadsource LIKE '%smarte%') THEN 'AI Informed List Provider'
		WHEN (l.leadsource LIKE '%Trade%' OR l.leadsource LIKE '%20%') THEN 'Trade Show'
		WHEN (l.leadsource LIKE '%Linked' OR l.leadsource LIKE '%LinkedIn%') THEN 'LinkedIn'
		WHEN (l.leadsource LIKE 'Contact%' OR l.leadsource LIKE '%email%') THEN 'Contact Us'
		WHEN l.leadsource LIKE '%Demo%' THEN 'Demo Request'
		WHEN l.leadsource LIKE '%utm%' THEN 'Marketing Campaign'
		WHEN (l.leadsource LIKE '%demand_exchange%' OR l.leadsource LIKE 'TM Subscriber%' OR l.leadsource LIKE '%Content Syndication%') THEN 'Content Syndication'
		WHEN (l.leadsource IS NULL AND c.leadsource IS NULL) THEN 'Unknown'
		ELSE l.leadsource 
		END 
		AS leadSource,
        c.leadsource AS contactLeadSource,
	l.customer_status__c,
	l.convertedaccountid,
        l.ownerid,
	u.full_name__c,
	l.convertedcontactid,
	c.id AS contactId,
	l.converteddate AS leadConvertedDate,
	l.company,
	l.full_salesforce_id__c,
	l.status,
	l.status_l__c ,
	l.createddate AS leadCreatedDate,
	CASE WHEN dp.partner_billing_country IS NULL THEN l.countrycode ELSE NULL END AS partner_billing_coutry,
	l.countrycode,
	l.region__c,
	l.domain__c 
FROM sf."lead" l 
LEFT JOIN sf.contact c 		ON c.id = l.convertedcontactid
LEFT JOIN ersdw.dim_partner dp ON dp.partner_sf_account_id = c.accountid 
LEFT JOIN sf."user" u 			ON u.id = l.ownerid AND u.full_name__c <> 'Harald Nuij'
WHERE 
l.company <> 'Wirehive'
)
SELECT *, 
CASE WHEN CTE_1.leadsource IS NULL THEN CTE_1.contactLeadSource ELSE CTE_1.leadsource END AS newLeadSource
FROM CTE_1