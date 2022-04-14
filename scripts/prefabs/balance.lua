--local easing = require("easing")

--[[
功能：
mod科技：制作狼牙手串
发身份牌

]]

local assets = 
{
	Asset("ATLAS", "images/inventoryimages/balance.xml"),
	Asset("ANIM", "anim/balance.zip"),
}
local assets_icon =
{
    --Asset("MINIMAP_IMAGE", "moonrockseed"),
}

local prefabs = 
{
	--"collapse_small",
    --"langyashouchuan",
}

local prefabs_icon =
{
    --"globalmapicon",
}

STRINGS.NAMES.BALANCE = "天平（暂定）"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BALANCE = "检查文本"

--blink?

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	--MakeObstaclePhysics(inst, .4)
    MakeInventoryPhysics(inst)

	--inst.MiniMapEntity:SetPriority(5)
	--inst.MiniMapEntity:SetIcon()

    inst.AnimState:SetBank("balance")--动画
    inst.AnimState:SetBuild("balance")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("balance")
    inst:AddTag("prototyper")

    --MakeInventoryFloatable(inst, "med", nil, 0.77) --漂浮

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inventoryitem")--放入物品栏
	inst.components.inventoryitem.imagename = "balance"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/balance.xml"
	inst:AddComponent("inspectable")--可以检查

    inst:AddComponent("prototyper")
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.BALANCE_ONE

	--inst:AddTag("structure")

    --MakeSnowCoveredPristine(inst)

	--inst:AddComponent("lootdropper") --会掉落物品

    --MakeMediumBurnable(inst, nil, nil, true)
    --MakeMediumPropagator(inst)
    --inst.components.burnable:SetOnBurntFn(onburnt)

    --inst:AddComponent("hauntable")
    --inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    --inst.components.hauntable:SetOnHauntFn(OnHaunt)

	--inst:ListenForEvent("onlearnednewtacklesketch", onlearnednewtacklesketch) -----没有函数？
	--inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end
--[[
local function icon_init(inst)
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon.MiniMapEntity:SetPriority(11)
    inst.icon:TrackEntity(inst)
end

local function iconfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("moonrockseed.png")
    inst.MiniMapEntity:SetPriority(11)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.icon = nil
    inst:DoTaskInTime(0, icon_init)
    inst.OnRemoveEntity = inst.OnRemoveEntity
    inst.persists = false

    return inst
end
]]

return Prefab("balance", fn, assets, prefabs)  --prefabs 可忽略 相关的prefab依赖
      --Prefab("moonrockseed_icon", iconfn, assets_icon, prefabs_icon)
      --MakePlacer("balance_placer", "balance", "balance", "idle")