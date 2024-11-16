-- dialect: postgresql
-- preview data set
select
    player_name,
    age,
    height,
    weight,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    gp,
    pts,
    reb,
    ast,
    netrtg,
    oreb_pct,
    dreb_pct,
    usg_pct,
    ts_pct,
    ast_pct,
    season
from
    public.player_seasons;
