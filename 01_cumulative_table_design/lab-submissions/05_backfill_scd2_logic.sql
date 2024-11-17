-- dialect: postgresql

with add_record_hash as (
    select
        actorid,
        actor,
        current_year,
        is_active,
        quality_class,
        md5(is_active::text || '~' || quality_class::text) as record_hash
    from actors
),

streak_started as (
    select
        actorid,
        actor,
        current_year,
        is_active,
        quality_class,
        record_hash,
        coalesce(lag(record_hash)
            over
            (
                partition by actorid
                order by
                    current_year
            ), '~')
        != record_hash
        as did_change
    from
        add_record_hash
),

streak_identified as (
    select
        actorid,
        actor,
        current_year,
        is_active,
        quality_class,
        record_hash,
        sum(case when did_change then 1 else 0 end)
            over (
                partition by actorid
                order by
                    current_year
            )
        as streak_identifier
    from
        streak_started
),

aggregated as (
    select
        actorid,
        actor,
        is_active,
        quality_class,
        record_hash,
        streak_identifier,
        min(current_year) as start_year,
        max(current_year) as end_year
    from
        streak_identified
    group by 1, 2, 3, 4, 5, 6
)

select
    actorid,
    actor,
    is_active,
    quality_class,
    record_hash,
    start_year,
    end_year
from
    aggregated
order by actorid, start_date;
