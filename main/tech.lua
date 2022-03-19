
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
local _G = GLOBAL
local require = _G.require

----修改科技树生成？---

local TechTree = require("techtree")

table.insert(TechTree.AVAILABLE_TECH, "TIANPIN")
table.insert(TechTree.BONUS_TECH, "TIANPIN")

TechTree.Create = function(t)
    t = t or {}
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        t[v] = t[v] or 0
    end
    return t
end

---------------------------------------------------------
----加入具体内容？----

_G.TECH.NONE.TIANPIN = 0
_G.TECH.TIANPIN_ONE = { TIANPIN = 1 }

for k,v in pairs(TUNING.PROTOTYPER_TREES) do
    v.TIANPIN = 0
end

TUNING.PROTOTYPER_TREES.TIANPIN_ONE = TechTree.Create({
    TIANPIN = 1,
})
---------------------------------------------------------
----修改制作配方，补充缺失部分

AddPrefabPostInit("player_classified", function(inst)
    inst.techtrees = _G.deepcopy(_G.TECH.NONE)
end)

for i, v in pairs(_G.AllRecipes) do
    if v.level.TIANPIN == nil then
        v.level.TIANPIN = 0
    end
end