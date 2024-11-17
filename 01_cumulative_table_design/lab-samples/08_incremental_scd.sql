-- dialect: postgresql

-- latest dimension values
-- i.e., answers the question: 
-- "what are the latest dimensions for a player"
with last_season_scd as (
    select * from players_scd
    where current_season = 1996
        and end_season = 1996
)

-- previous dimension values
-- i.e., values that were already "expired" or "replaced"
, historical_scd as (
    select
        player_name
        , scorer_class
        , is_active
        , start_season
        , end_season
    from players_scd
    where current_season = 1996
        and end_season < 1996
)

-- incoming data
, this_season_data as (
    select * from players
    where current_season = 1997
)

-- from the incoming data,
-- which are actually unchanged
, unchanged_records as (
    select
        ts.player_name
        , ts.scorer_class
        , ts.is_active
        , ls.start_season
        , ts.current_season as end_season
    from this_season_data as ts
    inner join last_season_scd as ls
        on ts.player_name = ls.player_name
    where ts.scorer_class = ls.scorer_class
        and ts.is_active = ls.is_active
)

-- from the incoming data,
-- which are actually changed
-- each "changed" unit will have two rows
-- containing the previous values and the new values
, changed_records as (
    select
        ts.player_name
        , unnest(array[
            row(
                ls.scorer_class
                , ls.is_active
                , ls.start_season
                , ls.end_season

            )::scd_type
            , row(
                ts.scorer_class
                , ts.is_active
                , ts.current_season
                , ts.current_season
            )::scd_type
        ]) as records
    from this_season_data as ts
    left join last_season_scd as ls
        on ts.player_name = ls.player_name
    where (
        ts.scorer_class != ls.scorer_class
        or ts.is_active != ls.is_active
    )
)

-- just unnest the STRUCT to make each fields
-- individual columns again
, unnested_changed_records as (

    select
        player_name
        , (records::scd_type).scorer_class as scorer_class
        , (records::scd_type).is_active as is_active
        , (records::scd_type).start_season as start_season
        , (records::scd_type).end_season as end_season
    from changed_records
)

-- from the incoming data,
-- which are new?
, new_records as (

    select
        ts.player_name
        , ts.scorer_class
        , ts.is_active
        , ts.current_season as start_season
        , ts.current_season as end_season
    from this_season_data as ts
    left join last_season_scd as ls
        on ts.player_name = ls.player_name
    where ls.player_name is null

)


select
    *
    , 1997 as current_season
from (
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
);
