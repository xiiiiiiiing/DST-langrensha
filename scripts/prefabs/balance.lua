--require "prefabutil"

--[[
功能：
mod科技：制作狼牙手串
发身份牌
参考泰拉瑞亚激活
ui面板？
]]

local assets = 
{
	Asset("ATLAS", "images/inventoryimages/balance.xml"),
	Asset("IMAGE", "images/inventoryimages/balance.tex"),
	Asset("ANIM", "anim/balance.zip"),
}

local prefabs = 
{
	--"collapse_small",
    --"langyashouchuan",
}

STRINGS.NAMES.BALANCE = "天平（暂定）"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BALANCE = "检查文本"

-------------灯光------------
local MAX_LIGHT_FRAME = 14
local MAX_LIGHT_RADIUS = 15

local function OnUpdateLight(inst, dframes)
	local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes*3
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(MAX_LIGHT_RADIUS * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._LightTask:Cancel()
        inst._LightTask = nil
    end
end

local function OnUpdateLightColour(inst)
    local red, green, blue = 1, 1, 1
	inst._lighttweener = inst._lighttweener + FRAMES * 1.25
	if inst._lighttweener > 2 * PI then
		inst._lighttweener = inst._lighttweener - 2*PI
	end

    if inst.gamestart:value() then
        red = 0.90
        green = 0.20
        blue = 0.20
    else
	    local x = inst._lighttweener
	    local s = .15
	    local b = 0.85
	    local sin = math.sin

		red = sin(x) * s + b - s
		green = sin(x + 2/3 * PI) * s + b - s
		blue = sin(x - 2/3 * PI) * s + b - s
    end

	inst.Light:SetColour(red, green, blue)
end

local function OnLightDirty(inst)
    if inst._LightTask == nil then
        inst._LightTask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)

	if not TheNet:IsDedicated() then
		if inst._islighton:value() then
			if inst._lightcolourtask == nil then
				inst._lighttweener = 0
				inst._lightcolourtask = inst:DoPeriodicTask(FRAMES, OnUpdateLightColour)
			end
		elseif inst._lightcolourtask ~= nil then
			inst._lightcolourtask:Cancel()
			inst._lightcolourtask = nil
		end
	end
end

local function TurnLightsOn(inst)
    inst._islighton:set(true)
    OnLightDirty(inst)
    inst._TurnLightsOnTask = nil
end

----------激活----------
local function TurnOn(inst, is_loading)
    if inst.is_on then
        return
    end
    inst.is_on = true

    inst.components.activatable.inactive = true -- to allow turning off
    --inst.components.trader.enabled = false      -- 激活状态可以trading吗？

    if is_loading then
        inst.AnimState:PlayAnimation("activated_idle", true)

        --enable_dynshadow(inst) 没有这个
    else
        inst.AnimState:PlayAnimation("activate")
        inst.AnimState:PushAnimation("activated_idle", true)

        --inst._ShadowDelayTask = inst:DoTaskInTime(4*FRAMES, enable_dynshadow)

    end

    inst.SoundEmitter:KillSound("beam")
    inst.SoundEmitter:PlaySound("terraria1/terrarium/shimmer_loop", "shimmer")
end

---··
local function OnActivate(inst, doer)
	if not inst.is_on then
		TurnOn(inst)
	else
		TurnOff(inst)
	end
end

local function TurnOff(inst)
    if not inst.is_on then
        return
    end

    inst.is_on = false
    inst.components.activatable.inactive = true    --为什么是true？
    inst.components.trader.enabled = true

    inst.components.timer:StopTimer("warning")

    if not inst.components.inventoryitem.canbepickedup then
        inst.components.inventoryitem.canbepickedup = true
    end

    inst.SoundEmitter:KillSound("shimmer")
    inst.SoundEmitter:KillSound("beam")

    if inst._TurnLightsOnTask ~= nil then
        inst._TurnLightsOnTask:Cancel()
        inst._TurnLightsOnTask = nil
    end
    inst._islighton:set(false)
    OnLightDirty(inst)

	-- The game is in limbo when it's in an inventory or container.
    --[[if inst:IsInLimbo() then
        inst.AnimState:PlayAnimation("idle", true)

        disable_dynshadow(inst)
    else
        inst.AnimState:PlayAnimation("deactivate")
        inst.AnimState:PushAnimation("idle", true)

        inst._ShadowDelayTask = inst:DoTaskInTime(4*FRAMES, disable_dynshadow)
    end]]
end

local function OnSave(inst, data) --保存游戏进度
    data.is_on = inst.is_on
    data.gamestart = inst.gamestart:value()

    local refs = nil
    --[[if inst.eyeofterror ~= nil then
        -- If the boss is dying as we save, record it.
        data.boss_dead = inst.eyeofterror:IsDying()

        data.boss_guid = inst.eyeofterror.GUID
        refs = { inst.eyeofterror.GUID }
    end
]]
    return refs
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.gamestart then
            --become_crimson(inst)
        end
    end
end

local function gamestart(inst)
	return inst.gamestart:value()
end

--------------游戏开始------------------
local function game_start_listeners(inst, game)
---补充游戏开始的动画
end


-------------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	--MakeObstaclePhysics(inst, .4)
    MakeInventoryPhysics(inst)
	--inst.MiniMapEntity:SetIcon("balance.png") 添加小地图的图标
	--inst.MiniMapEntity:SetPriority(5) 这个可以没有但也可以试一下
	
	inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.45)
    inst.Light:SetFalloff(1.8)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst.DynamicShadow:SetSize(1.25, 1)
    inst.DynamicShadow:Enable(false)

    inst.AnimState:SetBank("balance")--动画
    inst.AnimState:SetBuild("balance")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("balance")
	inst:AddTag("trader")
    --inst:AddTag("prototyper")

    --MakeInventoryFloatable(inst, "med", nil, 0.77) --漂浮
	
	--[[inst._LightTask = nil --灯光动画效果
    inst._lightframe = net_smallbyte(inst.GUID, "terrarium._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "terrarium._islighton", "lightdirty")
    inst._islighton:set(false)]]
	inst.gamestart = net_bool(inst.GUID, "terrarium._iscrimson", "lightdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inventoryitem")--放入物品栏
	inst.components.inventoryitem.imagename = "balance"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/balance.xml"
	inst:AddComponent("inspectable")--可以检查
	
	inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.quickaction = true
	inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR


    return inst
end

return Prefab("balance", fn, assets, prefabs)  --prefabs 可忽略 相关的prefab依赖
      --MakePlacer("balance_placer", "balance", "balance", "idle")