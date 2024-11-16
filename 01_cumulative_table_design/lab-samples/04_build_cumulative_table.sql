-- dialect: postgresql

-- query for building the cumulative table
do $$
begin
	-- made a loop to programmatically 
	-- backfill all available seasons
	for i_season in 1996..2022 loop
		insert into players
		with last_season as (
				select
					*
				from
					players
				where
					current_season = (
						i_season - 1
					)
			)
			, this_season as (
				select
					*
				from
					PLAYER_SEASONS
				where
					season = i_season
			)
		select
			coalesce(
				t.player_name
				, l.player_name
			) as player_name
			, coalesce(
				t.height
				, l.height
			) as height
			, coalesce(
				t.college
				, l.college
			) as college
			, coalesce(
				t.country
				, l.country
			) as country
			, coalesce(
				t.draft_year
				, l.draft_year
			) as draft_year
			, coalesce(
				t.draft_round
				, l.draft_round
			) as draft_round
			, coalesce(
				t.draft_number
				, l.draft_number
			) as draft_number
			, case
				when l.season_stats is null
				-- first time to see the player
				-- create array with single item
					then array[
						row(
					t.season
					, t.gp
					, t.pts
					, t.reb
					, t.ast
					, t.weight
				)::season_stats
					]
				when t.season is not null
				-- l.season_stats is not null, and we have season data
				-- create array with single item and append it to existing array
					then l.season_stats || array[
						row(
					t.season
					, t.gp
					, t.pts
					, t.reb
					, t.ast
					, t.weight
				)::season_stats
					]
				else
				-- l.season_stats is not null, but we don't have season data
				-- just return previous season's data (i.e., retain)
				-- so that we won't add a bunch of nulls to the array when there's no
				-- data for a player on this season (i.e., the player "retired")
				l.season_stats
			end as season_stats
			-- use this season's season otherwise, just increment
			-- note: i think the increment assumes that you load season data sequentially
			--		since this is cumulative table design
			, coalesce(
				t.season
				, l.current_season + 1
			) as current_season
			, case
				when t.season is not null
					then (
						case
						   when t.pts > 20 then 'star'
						when t.pts > 15 then 'good'
						when t.pts > 10 then 'average'
						else 'bad'
					end
				)::scoring_class
				else l.scorer_class
			end as scorer_class
			, t.season is not null as is_active
		from
			this_season t
		full outer join last_season l
			on
			t.player_name = l.player_name;
	end loop;
end;
$$
