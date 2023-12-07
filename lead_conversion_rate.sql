select 
    dl.lead_id,
    fl.fact_lead_contact_id,
    dl.lead_is_converted,
    dl.lead_created_date,
    dc.contact_created_date,
    DATEDIFF(day, dl.lead_created_date, dc.contact_created_date) AS datediff,
    dl.lead_first_name,
    dl.lead_last_name,
    dc.contact_first_name,
    dc.contact_last_name,
    dl.lead_status
from esdw.dim_lead dl 
left join 
    esdw.fact_lead fl on fl.fact_lead_id = dl.lead_id
left join 
    esdw.dim_contact dc on dc.contact_id = fl.fact_lead_contact_id
Where dl.lead_country in ('United States', 'Canada', 'US', 'CA')