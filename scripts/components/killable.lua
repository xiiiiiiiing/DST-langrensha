local Killable = Class(function(self, inst)
    self.inst = inst
end)

local reach_dist = 10
local lying_time = 60
-- 刺杀功能
function Killable:Kill(lamb)
    if lamb and self.inst:HasTag('player') and (lamb.components.health and not lamb.components.health:IsDead()) then
		
		local x1, y1, z1 = lamb.Transform:GetWorldPosition()
		local x2, y2, z2 = self.inst.Transform:GetWorldPosition()
		local dist = math.sqrt((x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2))
		
		if dist <= 0 then
			return
		end

		-- 睡眠部分代码
		if dist <= reach_dist then

			if lamb.sg.sg.states.hit then
				lamb.AnimState:PlayAnimation("hit") --这部分可以删除
			    lamb.AnimState:PlayAnimation("hit")
		    end

		  	if lamb.components.sleeper ~= nil then 
				lamb.components.sleeper:AddSleepiness(5, lying_time, self.inst)
			elseif lamb.components.grogginess ~= nil then
				lamb.components.grogginess:AddGrogginess(5, lying_time)
			end
		end
	--else
		--return
	end	
end

--[[
备忘录：
技能触发判定，开启技能才生效
只有狼人能看到
狼人加速，也可加到技能部分的代码中
加速范围判定
扣血
人物有特殊技能，人物在牛上
变身
判断时间（黄昏或晚上）
隐藏昵称，玩家位置暂停共享
cd
]]

return Killable