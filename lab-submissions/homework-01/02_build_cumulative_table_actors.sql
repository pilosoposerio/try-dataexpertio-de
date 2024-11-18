-- dialect: postgresql

with last_year as (
    select *
    from
        actors
    where
        current_year = 1969
)

, this_year as (
    select
        actorid
        , actor
        , year
        , array_agg(
            row(
                film
                , year
                , votes
                , rating
                , filmid
            )::film
        )::film [] as films
        , avg(rating) as average_rating
        , count(*) as films_count
    from
        actor_films
    where
        year = 1970
    group by
        actorid
        , actor
        , year
)

, cumulative_table as (
    select
        coalesce(
            t.actorid
            , l.actorid
        ) as actorid
        , coalesce(
            t.actor
            , l.actor
        ) as actor
        , case
            -- when first time encounter
            -- use the records from this year
            when l.films is null then t.films
            -- when not first encounter and there's new annual data
            -- append new data to old data
            when coalesce(
                    t.films_count
                    , 0
                ) > 0 then l.films || t.films
                -- otherwise, just retain old data
            else l.films
        end::film [] as films
        , coalesce(
            t.year
            , l.current_year + 1
        ) as current_year
        , case
            when coalesce(t.films_count, 0) > 0
                then (
                    case
                        when t.average_rating > 8 then 'star'
                        when t.average_rating > 7 then 'good'
                        when t.average_rating > 6 then 'average'
                        else 'bad'
                    end
                )::quality_class
            else l.quality_class
        end as quality_class
        , coalesce(t.films_count, 0) > 0 as is_active
    from
        last_year as l
    full outer join this_year as t
        on
            l.actorid = t.actorid
)

select *
from
    cumulative_table
order by actorid;
