--require "prefabutil"

--[[
功能：
mod科技：制作狼牙手串
发身份牌

]]

local assets = 
{
	Asset("ATLAS", "images/inventoryimages/tianpin.xml"),
	Asset("ANIM", "anim/tianpin.zip"),
}

local prefabs = 
{
	--"collapse_small",
    --"langyashouchuan",
}

STRINGS.NAMES.TIANPIN = "天平（暂定）"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TIANPIN = "检查文本"

--[[
local function MakePrototyper(inst) ----？？
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end

    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.JUDGESHRINE
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end
]]
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

    inst.AnimState:SetBank("tianpin")--动画
    inst.AnimState:SetBuild("tianpin")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("tianpin")
    inst:AddTag("prototyper")

    --MakeInventoryFloatable(inst, "med", nil, 0.77) --漂浮

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inventoryitem")--放入物品栏
	inst.components.inventoryitem.imagename = "tianpin"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tianpin.xml"
	inst:AddComponent("inspectable")--可以检查

    inst:AddComponent("prototyper")
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.TIANPIN_ONE

    MakeObstaclePhysics(inst, 0.4)
    

    --prototyper (from prototyper component) added to pristine state for optimization
    --inst:AddTag("prototyper")

	--inst:AddTag("structure")
    --inst:AddTag("tianpin")

    --MakeSnowCoveredPristine(inst)

    --inst._activetask = nil
    --inst._soundtasks = {}

	--inst:AddComponent("lootdropper") --会掉落物品

    --MakePrototyper(inst)

    --[[inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
    --MakeSnowCovered(inst)]]

	--inst:AddComponent("craftingstation")

    --[[inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.FISHING -- CARRATSHRINE
]]
    --MakeMediumBurnable(inst, nil, nil, true)
    --MakeMediumPropagator(inst)
    --inst.components.burnable:SetOnBurntFn(onburnt)

    --inst:AddComponent("hauntable")
    --inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    --inst.components.hauntable:SetOnHauntFn(OnHaunt)

	--inst:ListenForEvent("onlearnednewtacklesketch", onlearnednewtacklesketch) -----没有函数？
	--inst:ListenForEvent("onbuilt", onbuilt)

    --inst.OnSave = onsave
    --inst.OnLoad = onload

    return inst
end

return Prefab("tianpin", fn, assets, prefabs)  --prefabs 可忽略 相关的prefab依赖
      --MakePlacer("tianpin_placer", "tianpin", "tianpin", "idle")