-- dialect: postgresql
-- verify integrity of primary keys
select
    count(*) as cnt_rows,
    count(distinct coalesce(actorid, 'x') || '~' || coalesce(filmid, 'y')) as unique_rows
from
    public.actor_films;

-- check min,max years
select
    min(year) as min_year,
    max(year) as max_year
from
    public.actor_films;
-- 1970 - 2021
