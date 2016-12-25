local meta      = ...
local loader    = { }
local rotations = { }

local specID = GetSpecializationInfo(GetSpecialization())

function loader.rotationsDirectory()
    return GetWoWDirectory() .. '\\Interface\\AddOns\\meta\\meta\\rotations\\'
end

function loader.classDirectories()
    return GetSubdirectories(loader.rotationsDirectory()..'*')
end

function loader.specDirectories(class)
    return GetSubdirectories(loader.rotationsDirectory() .. class .. '\\*')
end

function loader.profiles(class, spec)
    return GetDirectoryFiles(loader.rotationsDirectory() .. class .. '\\' .. spec .. '\\*.lua')
end

-- Search each Class Folder in the Rotations Folder
for _, class in pairs(loader.classDirectories()) do
    -- Search each Spec Folder in the Class Folder
    for _, spec in pairs(loader.specDirectories(class)) do
        -- Search each Profile in the Spec Folder
        for _, profile in pairs(loader.profiles(class, spec)) do
            local rotation = require('rotations.'..class..'.'..spec..'.'..profile:sub(1, -5))
            if rotation then
                if rotation.profileID == specID then
                    print('|cffa330c9[meta] |r Rotation Found: |cFFFF0000' .. rotation.profileName)
                    meta.magic(rotation.rotation)
                    rotations[rotation.profileName] = rotation
                end
            end
        end
    end
end

-- for debug
_G['_rotations'] = rotations

-- run rotation
AddFrameCallback(function ()
    for k, v in pairs(rotations) do
       rotations[k].rotation()
       break
    end
end)

return loader
