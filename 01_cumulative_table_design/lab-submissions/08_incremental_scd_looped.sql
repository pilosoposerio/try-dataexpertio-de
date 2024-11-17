-- latest dimension values
-- i.e., answers the question: 
-- "what are the latest dimensions for an actor"
do $$
begin
-- made a loop to programmatically 
-- backfill all available seasons
for i_year IN 1970..2021 loop
insert into actors_scd
with last_year_scd as (
    select * from actors_scd
    where current_year = (i_year-1)
        and end_year = (i_year-1)
),

-- previous dimension values
-- i.e., values that were already "expired" or "replaced"
historical_scd as (
    select
        actorid,
        actor,
        quality_class,
        is_active,
        record_hash,
        start_year,
        end_year
    from actors_scd
    where current_year = (i_year-1)
        and end_year < (i_year-1)
),

-- incoming data
this_year_data as (
    select
        *,
        md5(is_active::text || '~' || quality_class::text) as record_hash
    from actors
    where current_year = i_year
),

-- from the incoming data,
-- which are actually unchanged
unchanged_records as (
    select
        ts.actorid,
        ts.actor,
        ts.quality_class,
        ts.is_active,
        ts.record_hash,
        ls.start_year,
        ts.current_year as end_year
    from this_year_data as ts
    inner join last_year_scd as ls
        on ts.actorid = ls.actorid
    where ts.record_hash = ls.record_hash
)
,
-- from the incoming data,
-- which are actually changed
-- each "changed" unit will have two rows
-- containing the previous values and the new values
changed_records as (
    select
        ts.actorid,
        ts.actor,
        array[
            row(
                ls.quality_class,
                ls.is_active,
                ls.record_hash,
                ls.start_year,
                ls.end_year
            )::scd_type,
            row(
                ts.quality_class,
                ts.is_active,
                ts.record_hash,
                ts.current_year,
                ts.current_year
            )::scd_type
        ] as records
    from this_year_data as ts
    left join last_year_scd as ls
        on ts.actorid = ls.actorid
    where ts.record_hash != ls.record_hash
),

-- just unnest the STRUCT to make each fields
-- individual columns again
unnested_changed_records as (
    select
        c.actorid,
        c.actor,
        r.*
    from changed_records as c, unnest(c.records) as r
)
,
-- from the incoming data,
-- which are new?
new_records as (

    select
        ts.actorid,
        ts.actor,
        ts.quality_class,
        ts.is_active,
        ts.record_hash,
        ts.current_year as start_year,
        ts.current_year as end_year
    from this_year_data as ts
    left join last_year_scd as ls
        on ts.actorid = ls.actorid
    where ls.actorid is null

),

final_records as (
    select *
    from historical_scd

    union all

    select *
    from unchanged_records

    union all

    select *
    from unnested_changed_records

    union all

    select *
    from new_records
)

select
    actorid,
    actor,
    is_active,
    quality_class,
    record_hash,
    start_year,
    end_year,
    i_year as current_year
from final_records;
end loop;
end;
$$
