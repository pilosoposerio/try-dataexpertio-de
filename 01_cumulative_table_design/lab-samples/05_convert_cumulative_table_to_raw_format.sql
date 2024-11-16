-- dialect: postgresql

-- convert cumulative table back to orignal input data format
-- only a subset of fields is used here to simplify
-- the main goal is to show how to `UNNEST` the array of structs
select
	p.player_name
	, s.*
from
	players p
	, unnest(p.season_stats) s
where
	p.current_season = 2001;

