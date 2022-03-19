GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
-- 待用/可能又用 ----------------

--GAME_STATE = false
--[[
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH
local TUNING = GLOBAL.TUNING
local Player = GLOBAL.ThePlayer
local TheNet = GLOBAL.TheNet
local IsServer = GLOBAL.TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput
local TimeEvent = GLOBAL.TimeEvent
local FRAMES = GLOBAL.FRAMES
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local EventHandler = GLOBAL.EventHandler
local SpawnPrefab = GLOBAL.SpawnPrefab
local State = GLOBAL.State
local DEGREES = GLOBAL.DEGREES
local Vector3 = GLOBAL.Vector3
local ACTIONS = GLOBAL.ACTIONS
local FOODTYPE = GLOBAL.FOODTYPE
local PLAYERSTUNLOCK = GLOBAL.PLAYERSTUNLOCK
local GetTime = GLOBAL.GetTime
local HUMAN_MEAT_ENABLED = GLOBAL.HUMAN_MEAT_ENABLED
local TheSim = GLOBAL.TheSim
local ActionHandler = GLOBAL.ActionHandler
]]
-----------------------------------------

PrefabFiles =
{
	"tianpin",
	"toothbracelet",
}

---------------配方及科技------------

--插入科技树
modimport "main/tech.lua" ---天平科技

env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

AddRecipe("toothbracelet", {Ingredient("rope", 1), Ingredient("houndstooth", 5)}, RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, nil,"images/inventoryimages/toothbracelet.xml") 
--------------------------

-- 狼人刺杀部分(暂时不知道这趴该放哪就先放main里面吧)--------------
AddPlayerPostInit(function(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("killable")
		inst:DoPeriodicTask(0.25,function()
			if inst.Transform and inst.Transform.GetRotation then
				inst.old_rotation = inst.Transform:GetRotation()
			end
		end)
	end
end)

-- actions ---------------
AddAction("KILL", "杀！", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag('player') and act.doer.components.killable and act.target:HasTag("player") and act.target ~= act.doer then
		act.doer.components.killable:Kill(act.target)
		return true
	else
		return false
	end
end)

-- components actions---------
AddComponentAction("SCENE", "killable", function(inst, doer, actions, right)
	if right then
		if inst:HasTag("player") and inst ~= doer then
			table.insert(actions, GLOBAL.ACTIONS.KILL)
		end
	end
end)

-- SG ------------
local state_kill = GLOBAL.State{ name = "kill",
	tags = { "doing", "busy" },

	onenter = function(inst)
		inst.components.locomotor:Stop()
		
		local handitem = nil
		if inst.components.inventory then
			handitem = inst.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HANDS]
		elseif inst.replica.inventory then
			handitem = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
		end
		if handitem then
			inst.AnimState:Hide("ARM_carry")
			inst.AnimState:Show("ARM_normal")
		end
		
		inst.AnimState:PlayAnimation("punch")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
		
		inst.sg.statemem.action = inst.bufferedaction
		inst.sg:SetTimeout(2)
		
		if not GLOBAL.TheWorld.ismastersim then
			inst:PerformPreviewBufferedAction()
		end
	end,

	timeline =
	{
		GLOBAL.TimeEvent(8 * GLOBAL.FRAMES, function(inst)
			if GLOBAL.TheWorld.ismastersim then
				inst:PerformBufferedAction()
			end
		end),
		GLOBAL.TimeEvent(15 * GLOBAL.FRAMES, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
	},
	
	onupdate = function(inst)
		if not GLOBAL.TheWorld.ismastersim then
			if inst:HasTag("doing") then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle", true)
			end
		end
	end,
	
	ontimeout = function(inst)
		local handitem = nil
		if inst.components.inventory then
			handitem = inst.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HANDS]
		elseif inst.replica.inventory then
			handitem = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
		end
		if handitem then
			inst.AnimState:Show("ARM_carry")
			inst.AnimState:Hide("ARM_normal")
		end
		
		if not GLOBAL.TheWorld.ismastersim then
			inst:ClearBufferedAction()  -- client
		end
		inst.sg:GoToState("idle")
	end,
	
	onexit = function(inst)
		local handitem = nil
		if inst.components.inventory then
			handitem = inst.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HANDS]
		elseif inst.replica.inventory then
			handitem = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
		end
		if handitem then
			inst.AnimState:Show("ARM_carry")
			inst.AnimState:Hide("ARM_normal")
		end
		
		if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
		end
		inst.sg.statemem.action = nil
	end,
}
AddStategraphState("wilson", state_kill)
AddStategraphState("wilson_client", state_kill)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.KILL, "kill"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.KILL, "kill"))

--狼人刀人部分完--------------
--------------------------------------------------------------------
