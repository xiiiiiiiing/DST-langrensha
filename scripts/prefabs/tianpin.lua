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

local function fn()
	local inst = CreatEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:SetPristine()

	--MakeObstaclePhysics(inst, .4)

	--inst.MiniMapEntity:SetPriority(5)
	--inst.MiniMapEntity:SetIcon()

    inst.AnimState:SetBank("tianpin")--动画
    inst.AnimState:SetBuild("tianpin")
    inst.AnimState:PlayAnimation("idle")
	
	inst.AddComoponent("inventoryitem")--放入物品栏
	inst.components.invnetoryitem.imagename = "tianpin"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tianpin.xml"
	isnt.AddComponent("inspectable")--可以检查

    --prototyper (from prototyper component) added to pristine state for optimization
    --inst:AddTag("prototyper")

	--inst:AddTag("structure")
    --inst:AddTag("judgeshrine")

    --MakeSnowCoveredPristine(inst)

    --inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst._activetask = nil
    --inst._soundtasks = {}

    --inst:AddComponent("inspectable")

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

return Prefab("tianpin", fn, assets, prefabs),  --prefabs 可忽略 相关的prefab依赖
	--MakePlacer("judgeshrine_placer", "judgeshrine", "judgeshrine", "idle")