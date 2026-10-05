with source as (

    select * from {{ source('customer_raw', 'customers') }}

)

select
    customer_id,
    customer_name
from source
