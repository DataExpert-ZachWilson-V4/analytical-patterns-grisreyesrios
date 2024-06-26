--Create table to perform aggregations of the nba_game_detials
create or replace table grisreyesrios.nba_game_details_aggregations as (
select     
    coalesce(gd.player_name, 'Overall') as player,
    coalesce(gd.team_abbreviation, 'Overall') as team,
    coalesce(cast(g.season as varchar), 'Overall') as season,

    --Aggregate player and team
    case   
        when grouping(gd.player_name, gd.team_abbreviation) = 0 then 'player_team'
        when grouping(gd.player_name, g.season) = 0 then 'player_season'
        when grouping(gd.team_abbreviation) = 0 then 'team'
    end as grouping_type,
    sum(gd.pts) as total_points,
    sum(if(
        (gd.team_id = g.home_team_id and g.home_team_wins = 1) or
        (gd.team_id = g.visitor_team_id and g.home_team_wins = 0),
        1,
        0
    )) as wins
from bootcamp.nba_game_details_dedup as gd
join bootcamp.nba_games as g on gd.game_id = g.game_id
group by grouping sets( 
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
))