-- dialect: postgresql
-- identify end points for season
select
	min(season) min_season
	, max(season) max_season
from
	public.player_seasons ;
-- 1996, 2022

