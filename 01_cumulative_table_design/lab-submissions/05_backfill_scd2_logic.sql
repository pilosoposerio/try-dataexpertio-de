with raw_data as (
    select
        actorid,
        actor,
        current_year,
        is_active,
        quality_class
    from actors
),

add_record_hash as (
    select
        r.*,
        md5(r.is_active::text || '~' || r.quality_class::text) as record_hash
    from raw_data as r
),

lead_lag as (
    select
        actorid,
        actor,
        current_year,
        is_active,
        quality_class,
        record_hash,
        lag(record_hash) over (partition by actorid order by current_year) as prev_record_hash
    from
        add_record_hash
),

scd as (
    select
        actorid,
        actor,
        is_active,
        quality_class,
        record_hash,
        make_date(current_year, 1, 1) as start_date,
        make_date(lead(current_year) over (partition by actorid order by current_year), 1, 1) as end_date
    from lead_lag
    where record_hash != coalesce(prev_record_hash, '~')
)

select * from scd
order by
    actorid,
    start_date;
