-- dialect: postgresql
-- create a composite type ("structs")
create type season_stats as (
    season integer
    , gp integer
    , pts real
    , reb real
    , ast real
    , weight real
);

create type scoring_class as
enum (
    'bad'
    , 'average'
    , 'good'
    , 'star'
);

-- create cumulative table
create table players (
    player_name text
    -- non changing values in the dataset
    , height text
    , college text
    , country text
    , draft_year text
    , draft_round text
    , draft_number text
    -- cumulated array of stats
    , season_stats season_stats []
    -- latest season available in the array
    , current_season integer
    -- stats computed using cumulation
    , scorer_class scoring_class
    , is_active boolean
    , primary key (
        player_name
        , current_season
    )
);
