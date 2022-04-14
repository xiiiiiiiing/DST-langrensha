--[[ 
新加图标
PROTOTYPER_DEFS = {
{moonrockseed				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_celestial.tex",			is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL};
}
]]
local Recipes = {
	--狼牙手串
	{
		name = "toothbracelet"
		Ingredient={
			ingredient("rope", 1),
			ingredient("houndstooth", 5),
		}
		tab = ,
		level = ,
		nonlock = true;

	},

}	

return{ Recipes = Recipes }



