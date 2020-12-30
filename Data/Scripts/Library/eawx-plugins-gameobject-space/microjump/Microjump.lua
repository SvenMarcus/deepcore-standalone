--*****************************************************************************
--*    _______ __
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.
--*     |   | |     |   _|  _  |  |  |  |     |__ --|
--*     |___| |__|__|__| |___._|________|__|__|_____|
--*    ______
--*   |   __ \.-----.--.--.-----.-----.-----.-----.
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|
--*   |___|__||_____|\___/|_____|__|__|___  |_____|
--*                                   |_____|
--*
--*   @Author:              [EaWX]Pox
--*   @Date:                2020-12-30
--*   @Project:             Empire at War Expanded
--*   @Filename:            Microjump.lua
--*   @License:             MIT
--*****************************************************************************

require("PGBase")
require("eawx-std/class")

---@class Microjump
Microjump = class()

function Microjump:new()
    self.on_cooldown = false
end

function Microjump:update()
    if Object.Is_Ability_Ready("WEAKEN_ENEMY") then
        self.on_cooldown = false
        return
    end

    if self.on_cooldown then
        return
    end

    local jump_marker = Find_Nearest(Object, "Microjump_Marker")
    if not TestValid(jump_marker) then
        return
    end

    self.on_cooldown = true
    local neutral = Find_Player("Neutral")
    local private_marker_type = Find_Object_Type("Private_Microjump_Marker")
    local private_jump_marker = Spawn_Unit(private_marker_type, jump_marker.Get_Position(), neutral)[1]
    jump_marker.Despawn()

    if not TestValid(private_jump_marker) then
        return
    end

    private_jump_marker.Highlight(true)
    private_jump_marker.Set_Selectable(false)
    Object.Set_Selectable(false)
    BlockOnCommand(Object.Turn_To_Face(private_jump_marker), -1)
    Register_Timer(self.JumpTimer, 3, private_jump_marker)
    Object.Suspend_Locomotor(true)
    Play_Lightning_Effect("Hyperspace_Lightning_Effect", Object.Get_Bone_Position("root"), private_jump_marker)
end

function Microjump.JumpTimer(private_marker)
    Object.Play_SFX_Event("Unit_Ship_Hyperspace_Enter")
    if TestValid(private_marker) then
        Object.Teleport(private_marker)
        private_marker.Highlight(false)
        private_marker.Despawn()
    end
    Object.Suspend_Locomotor(false)
    Object.Set_Selectable(true)
end

return Microjump
