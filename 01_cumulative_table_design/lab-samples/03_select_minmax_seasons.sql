-- dialect: postgresql
-- identify end points for season
select
    min(season) as min_season
    , max(season) as max_season
from
    public.player_seasons;
-- 1996, 2022
