-- Required to access other files.
local meta  = ...
local unit  = require('conditions.unit')
local spell = require('conditions.spell')
local spellList = require('conditions.spellList')

-- Init Buff
local cast = { }

-----------------------------------
--- Cast Related Functions Here ---
-----------------------------------
local idList = {}
idList = spellList.mergeIdTables(idList)
for k, v in pairs(idList.abilities) do
    cast[k] = function(unitCast)
        unitCast = unitCast or unit.getBest(v)
        print('Casting '..spell.name(v)..' with Id: '..v..' at: '..unitCast)
        CastSpellByName(spell.name(v),unitCast)
        if IsAoEPending() then
            local X,Y,Z = unit.position(unitCast)
            ClickPosition(X,Y,Z)
        end
        -- spell.last = spellCast
        -- unit.last = unitCast
    end
end

-- function cast.spell(spellCast,unitCast)
--     CastSpellByName(spellCast,unitCast)
--     if IsAoEPending() then
--         local X,Y,Z = unit.position(unitCast)
--         ClickPosition(X,Y,Z)
--     end
--     -- spell.last = spellCast
--     -- unit.last = unitCast
-- end

-- function cast.dead(spellCast,unitCast)
--     if unit.friend(unitCast) and unit.dead(unitCast) then
--         cast.spell(spellCast,unitCast)
--     end
-- end
--
-- function cast.enemy(spellCast,unitCast)
--     if unit.enemy(unitCast) and not unit.dead(unitCast) then
--         cast.spell(spellCast,unitCast)
--     end
-- end
--
-- function cast.friend(spellCast,unitCast)
--     if unit.friend(unitCast) and not unit.enemy(unitCast) and not unit.dead(unitCast) then
--         cast.spell(spellCast,unitCast)
--     end
-- end
--
-- function cast.best(spellCast)
--     -- TODO: Find best location to cast AoE for spells effective range for given minimal Units
-- end

function cast.check(spellCast,unitCast)
    unitCast = unitCast or unit.getBest(spellCast)
    return spell.usable(spellCast) and spell.cd(spellCast) == 0 and spell.known(spellCast) and spell.inRange(spellCast,unitCast) and unit.sight(unitCast)
    -- if spell.usable(spellCast) and spell.cd(spellCast) == 0 and spell.known(spellCast) and spell.inRange(spellCast,unitCast) and unit.sight(unitCast) then
    --     return true
    -- else
    --     return false
    -- end
end

-- Return Functions
return cast
