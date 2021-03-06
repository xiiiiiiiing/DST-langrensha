--[[
天平相关功能，祭品

]]

local assets = 
{
	Asset("ATLAS", "images/inventoryimages/toothbracelet.xml"),
	Asset("IMAGE", "images/inventoryimages/toothbracelet.tex"),
	Asset("ANIM", "anim/toothbracelet.zip"),
}

--不知道有啥用
local prefabs = 
{
	--"collapse_small",
}

--env.STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.TOOTHBRACELET = "狼牙手串"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOOTHBRACELET = "噢，是尖尖的牙呀！"
STRINGS.RECIPE_DESC.TOOTHBRACELET = "把狗牙串成一串"

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	--MakeObstaclePhysics(inst, .4)
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("toothbracelet")--动画
    inst.AnimState:SetBuild("toothbracelet")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inventoryitem")--放入物品栏
	inst.components.inventoryitem.imagename = "toothbracelet"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/toothbracelet.xml"
	inst:AddComponent("stackable")--可堆叠
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
	inst:AddComponent("inspectable")--可以检查
	MakeHauntableLaunch(inst)--作祟

    return inst
end

return Prefab("toothbracelet", fn, assets, prefabs)