-- dialect: postgresql

-- TYPE quality_class has already been defined at this point
create table actors_history_scd
(
    actorid text
    , actor text
    , is_active boolean
    , quality_class quality_class
    , record_hash text
    , start_year integer
    , end_year integer
    , current_year integer
    , primary key (actorid, current_year, start_year)
);
