require("deepcore/std/plugintargets")

return {
    target = PluginTargets.never(),
    init = function(self, ctx)
        local plot = Get_Story_Plot("STORY_SANDBOX_27_UNDERWORLD.XML")
        local screen_text = plot.Get_Event("Generic_Screen_Text")

        local plugin = {
            screen_text = screen_text,
            num_messages = 0,
            on_battle_end = function(self, mode_name)
                DebugMessage("battle-notification-service -- exiting %s mode", mode_name)
                self.screen_text.Set_Reward_Parameter(0, "GameScoring says: Entering Galactic Mode!")
                Story_Event("GENERIC_SCREEN_TEXT")
            end,
            on_msg = function(self, msg)
                self.num_messages = self.num_messages + 1
                if self.num_messages == 2 then
                    crossplot:unsubscribe("MESSAGE", self.on_msg, self)
                end
                self.screen_text.Set_Reward_Parameter(0, msg)
                Story_Event("GENERIC_SCREEN_TEXT")
            end
        }

        crossplot:subscribe("GAME_MODE_ENDING", plugin.on_battle_end, plugin)
        crossplot:subscribe("MESSAGE", plugin.on_msg, plugin)

        return plugin
    end
}