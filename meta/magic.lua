local meta = ...

-- setup the magic global stuff
local magic

-- load in all the base calls, conditions, etc
magic           = require('conditions.base')
magic.buff      = require('conditions.buff')
magic.cast      = require('conditions.cast')
magic.debuff    = require('conditions.debuff')
magic.health    = require('conditions.health')
magic.power     = require('conditions.power')
magic.spellList = require('conditions.spellList')
magic.spell     = require('conditions.spell')
magic.unit      = require('conditions.unit')
magic.combatlog = require('conditions.combatlog')

return function(func)
    return setfenv(func, setmetatable(magic, { __index = _G }))
end
