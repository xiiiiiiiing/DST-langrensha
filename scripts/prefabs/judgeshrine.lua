require "prefabutil"

--[[
功能：
mod科技：制作狼牙手串
发身份牌

]]

local assets =
{
	Asset("ANIM", "anim/judgeshrine.zip"),
    Asset("MINIMAP_IMAGE", "judgeshrine"),
}

--[[
local prefabs =
{
	"collapse_small",
}
]]

--[[
local sounds =
{
	onbuilt = "hookline/common/tackle_station/place",
	idle = "hookline/common/tackle_station/proximity_LP",
	learn = "hookline/common/tackle_station/recieive_item",
	use = "hookline/common/tackle_station/use",
}
]]

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	--inst.SoundEmitter:PlaySound(sounds.onbuilt)
end

local function MakePrototyper(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end

    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARRATSHRINE
    end
end

--[[
老鼠神龛部分
local function SetOffering(inst, offering, loading)
    if offering == inst.offering then
        return
    end

    DropOffering(inst) --Shouldn't happen, but w/e (just in case!?)

    inst.offering = offering
    inst:ListenForEvent("onremove", inst._onofferingremoved, offering)
    inst:ListenForEvent("perished", inst._onofferingperished, offering)
    inst:AddChild(offering)
    offering:RemoveFromScene()
    offering.Transform:SetPosition(0, 0, 0)

    if offering:HasTag("edible_SEEDS") then
        inst.AnimState:ClearOverrideSymbol("seeds01")
    elseif offering.prefab == "carrot" then
        inst.AnimState:OverrideSymbol("seeds01", "carrot", "carrot01")
    end
    inst.AnimState:Show("seeds")

    if not loading then
        inst.SoundEmitter:PlaySound("dontstarve/common/plant")
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("idle", false)
    end

    MakePrototyper(inst)
end

local function MakeEmpty(inst)
    if inst.offering ~= nil then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst.offering:Remove()
        inst.offering = nil
    end

    inst.AnimState:Hide("seeds")

    if inst.components.prototyper ~= nil then
        inst:RemoveComponent("prototyper")
    end

    if inst.components.trader == nil then
        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
        inst.components.trader.acceptnontradable = true
        inst.components.trader.deleteitemonaccept = false
        inst.components.trader.onaccept = ongivenitem
    end
end

local function OnIgnite(inst)
    if inst.offering ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    MakeEmpty(inst)
    inst.components.trader:Disable()
    DefaultBurnFn(inst)
end

local function OnExtinguish(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function OnOfferingPerished(inst)
    if inst.offering ~= nil then
        MakeEmpty(inst)
        local rot = SpawnPrefab("spoiled_food")
        rot.Transform:SetPosition(inst.Transform:GetWorldPosition())
        LaunchAt(rot, inst, nil, .5, 0.6, .6)
    end
end

渔具科技部分
local function giveitem(inst, itemname)
    inst.components.pickable:SetUp(itemname, 1000000)
    inst.components.pickable:Pause()
    if not inst.components.pickable.caninteractwith then
        inst.components.pickable.caninteractwith = true
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")
    end

    inst.AnimState:ClearOverrideSymbol("cutstone01")
    inst.AnimState:ClearOverrideSymbol("swap_body")
    inst.AnimState:OverrideSymbol(CalcSculptingSymbol(itemname), CalcSymbolFile(itemname), CalcItemSymbol(itemname))

    inst.components.prototyper.trees.SCULPTING = CalcSculptingTech(itemname)

    if string.find(inst.components.pickable.product, "rook")
        or string.find(inst.components.pickable.product, "bishop")
        or string.find(inst.components.pickable.product, "knight") then

        inst:AddTag("chess_moonevent")
    end
end

local function ongivenitem(inst, giver, item)
    if item:HasTag("sketch") then
        AddSketch(inst, item)
    else
        giveitem(inst, item.prefab)
    end
end
]]

local function onhammered(inst, worker)
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal") --掉落材料？
    inst:Remove()
end

--不知道干啥的
local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function OnHaunt(inst, haunter)
    if not inst:HasTag("burnt") and inst.components.prototyper.on then
        onuse(inst, false)
    else
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
    end
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    return true
end

local function onburnt(inst)
	DropTackleSketches(inst)
    inst.components.craftingstation:ForgetAllItems()

    DefaultBurntStructureFn(inst)
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetPriority(5)
	inst.MiniMapEntity:SetIcon()

    inst.AnimState:SetBank("judgeshrine")
    inst.AnimState:SetBuild("judgeshrine")
    inst.AnimState:PlayAnimation("idle")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

	inst:AddTag("structure")
    inst:AddTag("judgeshrine")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._activetask = nil
    inst._soundtasks = {}

    inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper") --会掉落物品
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("craftingstation")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.FISHING

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

	--inst:ListenForEvent("onlearnednewtacklesketch", onlearnednewtacklesketch) -----没有函数？
	inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("judgeshrine", fn, assets, prefabs),  --prefabs 可忽略 相关的prefab依赖
	MakePlacer("judgeshrine_placer", "judgeshrine", "judgeshrine", "idle")