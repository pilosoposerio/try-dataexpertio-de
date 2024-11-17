-- dialect: postgresql

-- convert cumulative table back to orignal input data format
-- only a subset of fields is used here to simplify
-- the main goal is to show how to `UNNEST` the array of structs
select
    s.*
    , p.player_name
from
    players as p
, unnest(p.season_stats) as s
where
    p.current_season = 2001;
