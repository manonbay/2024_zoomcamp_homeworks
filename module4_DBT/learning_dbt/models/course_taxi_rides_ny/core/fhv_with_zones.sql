{{config(materialized='table')}}

with fhv_tripdata as (select *, 'fhv' as service_type
    from {{ ref('stg_fhv2019') }}
    where pickup_location_id is not null and dropoff_location_id is not null),

dim_zones as (select * from {{ ref('dim_zones') }}
    where borough != 'Unknown')

select 
    fhv_tripdata.dispatching_base_num,
    fhv_tripdata.service_type,
    fhv_tripdata.pickup_datetime,
    fhv_tripdata.dropoff_datetime,
    fhv_tripdata.pickup_location_id,
    fhv_tripdata.dropoff_location_id,
    fhv_tripdata.affiliated_base_number,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  

from fhv_tripdata inner join dim_zones as pickup_zone
on fhv_tripdata.pickup_location_id = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_tripdata.dropoff_location_id = dropoff_zone.locationid

-- dbt build --select fhv_with_zones --vars '{'is_test_run': 'false'}'
{% if var("is_test_run", default=true) %} limit 100 {% endif %}
