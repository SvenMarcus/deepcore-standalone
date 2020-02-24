require("eawx-std/class")

---@class Planet
---@field private gameObject GameObject
Planet = class()

---@param name string
function Planet:new(name)
    ---@private
    self.gameObject = FindPlanet(name)
end

function Planet:get_owner()
    return self.gameObject.Get_Owner()
end

function Planet:get_game_object()
    return self.gameObject
end

---@return string
function Planet:get_name()
    return self.gameObject.Get_Type().Get_Name()
end

function Planet:has_structure(structure_name)
    local all_structures = Find_All_Objects_Of_Type(structure_name)
    for _, structure in pairs(all_structures) do
        if structure.Get_Planet_Location() == self.gameObject then
            return true
        end
    end

    return false
end

return Planet
