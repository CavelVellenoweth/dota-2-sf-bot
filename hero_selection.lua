----------------------------------------------------------------------------------------------------
function Think()


	if ( GetTeam() == TEAM_RADIANT )
	then
		SelectHero( 0, "npc_dota_hero_nevermore" );
		SelectHero( 1, "npc_dota_hero_dark_willow");
		SelectHero( 2, "npc_dota_hero_dark_willow");
		SelectHero( 3, "npc_dota_hero_dark_willow");
		SelectHero( 4, "npc_dota_hero_dark_willow");
	elseif ( GetTeam() == TEAM_DIRE )
	then
		print( "selecting dire" );
		SelectHero( 5, "npc_dota_hero_nevermore" );
		SelectHero( 6, "npc_dota_hero_dark_willow");
		SelectHero( 7, "npc_dota_hero_dark_willow");
		SelectHero( 8, "npc_dota_hero_dark_willow");
		SelectHero( 9, "npc_dota_hero_dark_willow");
	end

end
----------------------------------------------------------------------------------------------------
