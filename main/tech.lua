
----修改科技树生成？---

local TechTree = require("techtree")

table.insert(TechTree.AVAILABLE_TECH, "JUDGESHRINE")

TechTree.Create = function(t)
    t = t or {}
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        t[v] = t[v] or 0
    end
    return t
end

---------------------------------------------------------
----加入具体内容？----

TECH.NONE.JUDGESHRINE = 0
TECH.JUDGESHRINE = { JUDGESHRINE = 1 }

for k,v in pairs(TUNING.PROTOTYPER_TREES) do
    v.JUDGESHRINE = 0
end

TUNING.PROTOTYPER_TREES.JUDGESHRINE = TechTree.Create({
    JUDGESHRINE = 1,
})
---------------------------------------------------------
----修改制作配方，补充缺失部分

for i, v in pairs(AllRecipes) do
    if v.level.JUDGESHRINE == nil then
        v.level.JUDGESHRINE = 0
    end
end