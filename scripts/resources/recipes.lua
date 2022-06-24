--使用mod材料
local function MedalIngredient(ingredienttype,amount)
	local atlas=resolvefilepath_soft("images/"..ingredienttype..".xml")
	return Ingredient(ingredienttype,amount,atlas)
end

local function Recipes = {
	{
		name = "toothbracelet",
		ingredients = {
			{
				Ingredient("rope", 1), I
				Ingredient("houndstooth", 5),
			},
		},
		level = TECH.SCIENCE_TWO,
		filters = {"REFINE"},
		atlas = "images/inventoryimages/toothbracelet.xml"	
	},
}

return {
	Recipes = Recipes,
	DeconstructRecipes = DeconstructRecipes,
}