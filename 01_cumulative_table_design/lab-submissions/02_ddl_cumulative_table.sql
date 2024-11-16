-- dialect: postgresql
-- create a composite type ("structs")

create type film as (
    film TEXT,
    "year" INT,
    votes INT,
    rating REAL,
    filmid TEXT
);

create type quality_class as
enum (
    'bad',
    'average',
    'good',
    'star'
);
-- DDL for cumulative table
create table actors (
    actorid text,
    actor text,
    films film [],
    current_year int,
    quality_class quality_class,
    is_active boolean
);
