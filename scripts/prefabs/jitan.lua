require "prefabutil"

--[[
功能：
发身份牌
mod科技
]]

local assets =
{
	Asset("ANIM", "anim/jitan.zip"),
    Asset("MINIMAP_IMAGE", "jitan"),
}

--[[
local prefabs =
{
	
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

--[[
local function onburnt(inst)
	DropTackleSketches(inst)
    inst.components.craftingstation:ForgetAllItems()

    DefaultBurntStructureFn(inst)
end
]]

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
	inst.MiniMapEntity:SetIcon("jitan.png")

    inst.AnimState:SetBank("tackle_station")
    inst.AnimState:SetBuild("tackle_station")
    inst.AnimState:PlayAnimation("idle")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

	inst:AddTag("structure")
	inst:AddTag("tacklestation")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._activetask = nil
    inst._soundtasks = {}

    inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
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

    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

	inst:ListenForEvent("onlearnednewtacklesketch", onlearnednewtacklesketch)
	inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("jitan", fn, assets, prefabs),
	MakePlacer("jitan_placer", "jitan", "jitan", "idle")