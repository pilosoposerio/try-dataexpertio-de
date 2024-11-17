-- dialect: postgresql  
with streak_started as (
    select
        player_name
        , current_season
        , scorer_class
        , lag(scorer_class, 1) over (partition by player_name order by current_season) != scorer_class
        or lag(scorer_class, 1) over (partition by player_name order by current_season) is null as did_change
    from players
)

, streak_identified as (
    select
        player_name
        , scorer_class
        , current_season
        , sum(case when did_change then 1 else 0 end)
            over (partition by player_name order by current_season)
        as streak_identifier
    from streak_started
)

, aggregated as (
    select
        player_name
        , scorer_class
        , streak_identifier
        , min(current_season) as start_date
        , max(current_season) as end_date
    from streak_identified group by 1, 2, 3
)

select
    player_name
    , scorer_class
    , start_date
    , end_date
from aggregated
