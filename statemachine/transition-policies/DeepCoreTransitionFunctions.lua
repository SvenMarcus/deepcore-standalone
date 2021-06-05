require("deepcore/std/callable")
require("eawx-util/ChangeOwnerUtilities")
require("eawx-util/StoryUtil")

TransitionFunctions = {}

---@param planets table<number, Planet>
---@param new_owner_name string
function TransitionFunctions.transfer_planet_ownership(planets, new_owner_name)
    return callable {
        planets = planets,
        new_owner = Find_Player(new_owner_name),
        call = function(self)
            self.Active_Planets = StoryUtil.GetSafePlanetTable()
            for _, planet in pairs(self.planets) do
                if self.Active_Planets[planet:get_name()] then
                    ChangePlanetOwnerAndRetreat(planet:get_game_object(), self.new_owner)
                end
            end
        end
    }
end

---@param planets table<number, Planet>
---@param required_owner_name string
---@param new_owner_name string
function TransitionFunctions.transfer_planet_ownership_if_owned_by_faction(planets, required_owner_name, new_owner_name)
    return callable {
        new_owner = Find_Player(new_owner_name),
        required_owner = Find_Player(required_owner_name),
        call = function(self)
            self.Active_Planets = StoryUtil.GetSafePlanetTable()

            ---@param planet Planet
            for _, planet in pairs(self.planets) do
                if self.Active_Planets[planet:get_name()] then
                    if planet:get_owner() == self.required_owner then
                       ChangePlanetOwnerAndRetreat(planet:get_game_object(), self.new_owner)
                    end
                end
            end
        end
    }
end

---@param required_owner_name string
---@param new_owner_name string
function TransitionFunctions.transfer_all_planets_owned_by_faction(required_owner_name, new_owner_name)
    return callable {
        new_owner = Find_Player(new_owner_name),
        required_owner = Find_Player(required_owner_name),
        call = function(self)
            local planets = FindPlanet.Get_All_Planets()
            ---@param planet Planet
            for _, planet in pairs(planets) do
                if planet:get_owner() == self.required_owner then
                    ChangePlanetOwnerAndReplace(planet:get_game_object(), self.new_owner)
                end
            end
        end
    }
end

---@param faction_name string
---@param tech_level number
function TransitionFunctions.set_tech_level_for_faction(faction_name, tech_level)
    return callable {
        faction_name = faction_name,
        tech_level = tech_level,
        call = function(self)
            local faction = Find_Player(self.faction_name)
            if not faction then
                return
            end

            StoryUtil.SetTechLevel(faction, self.tech_level)
        end
    }
end

---@param faction_list table<number, PlayerObject>
---@param tech_level number
function TransitionFunctions.set_tech_level_for_factions(faction_list, tech_level)
    return callable {
        tech_level = tech_level,
        call = function(self)
            for _, faction_name in pairs(faction_list) do
                local faction = Find_Player(faction_name)
                local target_tech_level = self.tech_level
                if not faction then
                    return
                end
                if faction == Find_Player("Rebel") then
                    target_tech_level = self.tech_level - 1
                end
                StoryUtil.SetTechLevel(faction, target_tech_level)
            end
        end
    }
end


---@param transition_functions table<number, fun()>
function TransitionFunctions.compose(transition_functions)
    return callable {
        transition_functions = transition_functions,
        call = function(self)
            for _, transition_function in ipairs(self.transition_functions) do
                transition_function()
            end
        end
    }
end
