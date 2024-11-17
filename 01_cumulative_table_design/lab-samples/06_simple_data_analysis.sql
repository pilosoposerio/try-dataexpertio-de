-- dialeect: postgresql

-- a simple query on how to do data analysis
-- on cumulative table without using any `GROUP BY`s
select
    player_name
    , season_stats[cardinality(season_stats)].pts / (
        case
            when season_stats[1].pts = 0
                then 1
            else season_stats[1].pts
        end
    ) as improvement_rate
from players
where current_season = 2001
order by improvement_rate desc;
