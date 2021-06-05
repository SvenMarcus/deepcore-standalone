require("pgcommands")
require("deepcore/std/deepcore")

-- Don't pool...
ScriptPoolCount = 0

--
-- Base_Definitions -- sets up the base variable for this script.
--
-- @since 3/15/2005 3:55:03 PM -- BMH
--
function Base_Definitions()
    DebugMessage("%s -- In Base_Definitions", tostring(Script))

    Common_Base_Definitions()

    ServiceRate = 0.1

    frag_index = 1
    death_index = 2
    GameStartTime = 0

    CampaignGame = false

    Reset_Stats()

    if Definitions then
        Definitions()
    end

    GameScoringPluginRunner = nil

    Define_Title_Faction_Table()
end

--
-- The player list has been reset underneath us, reset the stats.
--
-- @since 5/5/2005 7:43:17 PM -- BMH
--
function Player_List_Reset()
    GameScoringMessage("GameScoring -- PlayerList Reset.")
    Reset_Stats()
end

--
-- main script function.  Does event pumps and servicing.
--
-- @since 3/15/2005 3:55:03 PM -- BMH
--
function main()
    DebugMessage("GameScoring -- In main.")

    if GameService then
        while true do
            GameService()
            PumpEvents()
            if GameScoringPluginRunner then
                GameScoringPluginRunner:update()
            end
        end
    end

    ScriptExit()
end

--
-- Reset the Tactical mode game stats.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
--
function Reset_Tactical_Stats()
    GameScoringMessage("GameScoring -- Resetting tactical stats.")
    -- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
    TacticalKillStatsTable = {[frag_index] = {}, [death_index] = {}}
    TacticalTeamKillStatsTable = {[frag_index] = {}, [death_index] = {}}

    -- [playerid][planetname][object_type][build_count, credits_spent, combat_power]
    TacticalBuildStatsTable = {}

    -- a dirty hack to reset tactical script registry values
    ResetTacticalRegistry()
end

function GameScoringMessage(...)
    _ScriptMessage(string.format(unpack(arg)))
    _OuputDebug(string.format(unpack(arg)) .. "\n")
end

--
-- Reset all the stats and player lists.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
--
function Reset_Stats()
    GameScoringMessage("GameScoring -- Resetting stats.")

    Reset_Tactical_Stats()
    -- [frag|death][playerid][object_type][build_count, credits_spent, combat_power]
    GalacticKillStatsTable = {[frag_index] = {}, [death_index] = {}}

    -- [playerid][planetname][object_type][build_count, credits_spent, combat_power]
    GalacticBuildStatsTable = {}

    -- [playerid][object_type][neutralized_count]
    GalacticNeutralizedTable = {}

    -- [playerid][planet_type][sacked_count, lost_count]
    GalacticConquestTable = {}
    PlayerTable = {}
    PlayerQuitTable = {}
end

function ResetTacticalRegistry()
    DebugMessage("Resetting Allow_AI_Controlled_Fog_Reveal to 1 (allowed)")
    GlobalValue.Set("Allow_AI_Controlled_Fog_Reveal", 1)
end

--
-- Update our GameStats table with build stats
--
-- @param stat_table    stat table to update
-- @param planet        planet where the object was produced
-- @param object_type   the object type that was just produced
-- @since 3/18/2005 3:48:32 PM -- BMH
--
function Update_Build_Stats_Table(stat_table, planet, object_type, owner, build_cost)
    Update_Player_Table(owner)

    if planet then
        planet_type = planet.Get_Type()
        planet_name = planet_type.Get_Name()
    else
        planet_type = 1
        planet_name = "Unknown"
    end

    combat_power = object_type.Get_Combat_Rating()
    score_value = object_type.Get_Score_Cost_Credits()
    owner_id = owner.Get_ID()

    GameScoringMessage(
        "GameScoring -- %s produced %s at %s.",
        PlayerTable[owner_id].Get_Name(),
        object_type.Get_Name(),
        planet_name
    )

    player_entry = stat_table[owner_id]
    if player_entry == nil then
        player_entry = {}
    end

    planet_entry = player_entry[planet_type]
    if planet_entry == nil then
        planet_entry = {}
    end

    type_entry = planet_entry[object_type]
    if type_entry == nil then
        type_entry = {build_count = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
    else
        type_entry.build_count = type_entry.build_count + 1
        type_entry.combat_power = type_entry.combat_power + combat_power
        type_entry.build_cost = type_entry.build_cost + build_cost
        type_entry.score_value = type_entry.score_value + score_value
    end

    planet_entry[object_type] = type_entry
    player_entry[planet_type] = planet_entry
    stat_table[owner_id] = player_entry
end

--
-- Print out the current build statistics for all the players.
--
-- @param stat_table    stats table to display.
-- @since 3/21/2005 10:34:07 AM -- BMH
--
function Print_Build_Stats_Table(stat_table)
    GameScoringMessage("GameScoring -- Build Stats dump.")

    totals_table = {}

    for owner_id, player_entry in pairs(stat_table) do
        build_count = 0
        cost_count = 0
        power_count = 0
        score_count = 0

        GameScoringMessage("\tPlayer %s:", PlayerTable[owner_id].Get_Name())
        for planet_type, planet_entry in pairs(player_entry) do
            if planet_type == 1 then
                GameScoringMessage("\t\t%20s:", "Tactical")
            else
                GameScoringMessage("\t\t%20s:", planet_type.Get_Name())
            end
            for object_type, type_entry in pairs(planet_entry) do
                GameScoringMessage(
                    "\t\t%40s: %d : %d : $%d : %d",
                    object_type.Get_Name(),
                    type_entry.build_count,
                    type_entry.combat_power,
                    type_entry.build_cost,
                    type_entry.score_value
                )
                build_count = build_count + type_entry.build_count
                cost_count = cost_count + type_entry.build_cost
                power_count = power_count + type_entry.combat_power
                score_count = score_count + type_entry.score_value
            end
        end

        GameScoringMessage("\tTotal Builds: %d : %d : $%d : %d", build_count, power_count, cost_count, score_count)
        totals_table[owner_id] = {
            build_count = build_count,
            cost_count = cost_count,
            power_count = power_count,
            score_count = score_count
        }
    end
end

--
-- Print out the current statistics for all the players.
--
-- @param stat_table    stats table to display.
-- @since 3/15/2005 5:55:55 PM -- BMH
--
function Print_Stat_Table(stat_table)
    frag_table = {}

    GameScoringMessage("Frags:")
    for k, v in pairs(stat_table[frag_index]) do
        tkills = 0
        tpower = 0
        tscore = 0

        GameScoringMessage("\tPlayer %s:", PlayerTable[k].Get_Name())
        for kk, vv in pairs(v) do
            GameScoringMessage("\t%40s: %d : %d : %d", kk.Get_Name(), vv.kills, vv.combat_power, vv.score_value)
            tkills = tkills + vv.kills
            tpower = tpower + vv.combat_power
            tscore = tscore + vv.score_value
        end

        GameScoringMessage("\tTotal Frags: %d : %d : %d", tkills, tpower, tscore)
        frag_table[k] = {kills = tkills, combat_power = tpower, score_value = tscore}
    end

    death_table = {}

    GameScoringMessage("Deaths:")
    for k, v in pairs(stat_table[death_index]) do
        tkills = 0
        tpower = 0
        tscore = 0

        GameScoringMessage("\tPlayer %s:", PlayerTable[k].Get_Name())
        for kk, vv in pairs(v) do
            GameScoringMessage("\t%40s: %d : %d : %d", kk.Get_Name(), vv.kills, vv.combat_power, vv.score_value)
            tkills = tkills + vv.kills
            tpower = tpower + vv.combat_power
            tscore = tscore + vv.score_value
        end

        GameScoringMessage("\tTotal Deaths: %d : %d : %d", tkills, tpower, tscore)
        death_table[k] = {kills = tkills, combat_power = tpower, score_value = tscore}
    end

    for k, player in pairs(PlayerTable) do
        ft = frag_table[k]
        dt = death_table[k]
        if ft == nil or ft.kills == 0 then
            GameScoringMessage("\tPlayer %s, Weighted Kill Ratio: 0.0", player.Get_Name())
        elseif dt == nil or dt.kills == 0 then
            GameScoringMessage("\tPlayer %s, Weighted Kill Ratio: %d", player.Get_Name(), ft.kills)
        else
            GameScoringMessage("\tPlayer %s, Weighted Kill Ratio: %f", player.Get_Name(), ft.kills / dt.kills)
        end
    end
end

--
-- Script service function.  Just prints out the current stats.
--
-- @since 3/15/2005 3:56:43 PM -- BMH
--
function GameService()
    -- GameScoringMessage("GameScoring -- Tactical Stats dump.")
    -- Print_Stat_Table(TacticalKillStatsTable)
    -- GameScoringMessage("GameScoring -- Galactic Stats dump.")
    -- Print_Stat_Table(GalacticKillStatsTable)
    -- Print_Build_Stats_Table(GalacticBuildStatsTable)
    -- Print_Build_Stats_Table(TacticalBuildStatsTable)
    -- Debug_Print_Score_Vals()
end

--
-- Updates the table of players for the current game.
--
-- @param player    player object to add to our table of players
-- @since 3/15/2005 3:56:43 PM -- BMH
--
function Update_Player_Table(player)
    if player == nil then
        return
    end

    ent = PlayerTable[player.Get_ID()]
    if ent == nil then
        PlayerTable[player.Get_ID()] = player
    end
    ent = nil
end

--
-- Update our GameStats table with victim, killer info.
--
-- @param stat_table    stat table to update
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Update_Kill_Stats_Table(stat_table, object, killer)
    if TestValid(object) == false or TestValid(killer) == false then
        return
    end

    Update_Player_Table(killer)
    Update_Player_Table(object.Get_Owner())

    object_type = object.Get_Game_Scoring_Type()
    score_value = object.Get_Game_Scoring_Type().Get_Score_Cost_Credits()
    combat_power = object.Get_Game_Scoring_Type().Get_Combat_Rating()
    build_cost = object.Get_Game_Scoring_Type().Get_Build_Cost()
    killer_id = killer.Get_ID()
    owner_id = object.Get_Owner().Get_ID()

    GameScoringMessage("GameScoring -- Object: %s, was killed by %s.", object_type.Get_Name(), killer.Get_Name())

    -- Update frags
    frag_entry = stat_table[frag_index]
    if frag_entry == nil then
        frag_entry = {}
    end

    entry = frag_entry[killer_id]
    if entry == nil then
        entry = {}
    end

    pe = entry[object_type]
    if pe == nil then
        pe = {kills = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
    else
        pe.kills = pe.kills + 1
        pe.combat_power = pe.combat_power + combat_power
        pe.build_cost = pe.build_cost + build_cost
        pe.score_value = pe.score_value + score_value
    end

    entry[object_type] = pe
    frag_entry[killer_id] = entry
    stat_table[frag_index] = frag_entry

    -- Update deaths
    death_entry = stat_table[death_index]
    if death_entry == nil then
        death_entry = {}
    end

    entry = death_entry[owner_id]
    if entry == nil then
        entry = {}
    end

    pe = entry[object_type]
    if pe == nil then
        pe = {kills = 1, combat_power = combat_power, build_cost = build_cost, score_value = score_value}
    else
        pe.kills = pe.kills + 1
        pe.combat_power = pe.combat_power + combat_power
        pe.build_cost = pe.build_cost + build_cost
        pe.score_value = pe.score_value + score_value
    end

    entry[object_type] = pe
    death_entry[owner_id] = entry
    stat_table[death_index] = death_entry
end

----------------------------------------
--
--      E V E N T   H A N D L E R S
--
----------------------------------------

--
-- This event is triggered on a game mode start.
--
-- @param mode_name    name of the new mode (ie: Galactic, Land, Space)
-- @since 3/15/2005 3:58:59 PM -- BMH
--
function Game_Mode_Starting_Event(mode_name, map_name)
    GameScoringMessage("GameScoring -- Mode %s (%s) now starting.", mode_name, map_name)
    LastModeName = mode_name
    LastMapName = map_name

    if StringCompare(mode_name, "Galactic") then
        -- Galactic Campaign
        if not GameScoringPluginRunner then
            GameScoringPluginRunner = deepcore:gamescoring {
                plugin_folder = "eawx-plugins/gamescoring"
            }
        end

        CampaignGame = true
        Reset_Stats()
        GameStartTime = GetCurrentTime.Frame()
    elseif CampaignGame == false then
        -- Skirmish tactical
        Reset_Stats()
        GameStartTime = GetCurrentTime.Frame()
    elseif CampaignGame == true then
        -- Galactic transition to Tactical.
        -- cleaning out full galactic tables for performance reasons
        Reset_Tactical_Stats()
    end
    crossplot:publish("GAME_MODE_STARTING", mode_name)
    LastWasCampaignGame = CampaignGame
end

--
-- This event is triggered on a game mode end.
--
-- @param mode_name    name of the old mode (ie: Galactic, Land, Space)
-- @since 3/15/2005 3:58:59 PM -- BMH
--
function Game_Mode_Ending_Event(mode_name)
    GameScoringMessage("GameScoring -- Mode %s now ending.", mode_name)

    LastWasCampaignGame = CampaignGame
    if StringCompare(mode_name, "Galactic") then
        CampaignGame = false
    end
    
    crossplot:publish("GAME_MODE_ENDING", mode_name)
end

--
-- This event is triggered when a player quits the game.
--
-- @param player		the player that just quit
-- @since 8/25/2005 10:00:54 AM -- BMH
--
function Player_Quit_Event(player)
    Update_Player_Table(player)

    if player == nil then
        return
    end

    PlayerQuitTable[player.Get_ID()] = true
end

--
-- This event is triggered when a unit is destroyed in a tactical game mode.
--
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Tactical_Unit_Destroyed_Event(object, killer)
    Update_Kill_Stats_Table(TacticalKillStatsTable, object, killer)
end

--
-- This event is triggered when a unit is destroyed in the galactic game mode.
--
-- @param object        the object that was destroyed
-- @param killer        the player that killed this object
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Galactic_Unit_Destroyed_Event(object, killer)
    local object_type = object.Get_Type()

    if object_type.Is_Hero() and not object.Is_Category("Structure") then
        crossplot:publish("GALACTIC_HERO_KILLED", object_type.Get_Name())
    end

    Update_Kill_Stats_Table(GalacticKillStatsTable, object, killer)
    Update_Kill_Stats_Table(TacticalTeamKillStatsTable, object, killer)
end

--
-- This event is triggered when production has begun on an item at a given planet
--
-- @param planet        the planet that will produce this object
-- @param object_type   the object type scheduled for production
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Galactic_Production_Begin_Event(planet, object_type)
    --Track credits spent
    crossplot:publish("PRODUCTION_STARTED", planet.Get_Type().Get_Name(), object_type.Get_Name())
end

--
-- This event is triggered when production has been prematurely canceled
-- on an item at a given planet
--
-- @param planet        the planet that was producing this object
-- @param object_type   the object type that got canceled
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Galactic_Production_Canceled_Event(planet, object_type)
    --Track credits spent
    crossplot:publish("PRODUCTION_CANCELED", planet.Get_Type().Get_Name(), object_type.Get_Name())
end

--
-- This event is triggered when production has finished in a tactical mode
--
-- @param object_type   the object type that was just built
-- @param player			the player that built the object.
-- @param location		the location that built the object(could be nil)
-- @since 8/22/2005 6:11:07 PM -- BMH
--
function Tactical_Production_End_Event(object_type, player, location)
    Update_Build_Stats_Table(
        TacticalBuildStatsTable,
        location,
        object_type,
        player,
        object_type.Get_Tactical_Build_Cost()
    )
end

--
-- This event is triggered when production has finished on an item at a given planet
--
-- @param planet        the planet that produced this object
-- @param object        the object that was just created
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Galactic_Production_End_Event(planet, object)
    if object.Get_Type == nil then
        -- object must be a GameObjectTypeWrapper not a GameObjectWrapper if it doesn't
        -- have a Get_Type function.
        Update_Build_Stats_Table(GalacticBuildStatsTable, planet, object, planet.Get_Owner(), object.Get_Build_Cost())
    else
        crossplot:publish("PRODUCTION_FINISHED", planet.Get_Type().Get_Name(), object.Get_Type().Get_Name())
        -- object points to the GameObjectWrapper that was just created.
        Update_Build_Stats_Table(
            GalacticBuildStatsTable,
            planet,
            object.Get_Game_Scoring_Type(),
            planet.Get_Owner(),
            object.Get_Game_Scoring_Type().Get_Build_Cost()
        )
    end
end

function fake_get_owner()
    return fake_object_player
end

function fake_get_type()
    return fake_object_type
end

function fake_is_valid()
    return true
end

--
-- This event is triggered when the level of a starbase changes
--
-- @param planet        the planet where the starbase is located
-- @param old_type      the old starbase type
-- @param new_type      the new starbase type
-- @since 3/15/2005 4:10:19 PM -- BMH
--
function Galactic_Starbase_Level_Change(planet, old_type, new_type)
    GameScoringMessage(
        "GameScoring -- %s Starbase changed from %s to %s.",
        planet.Get_Type().Get_Name(),
        tostring(old_type),
        tostring(new_type)
    )

    if old_type == nil then
        return
    end
    if new_type ~= nil then
        return
    end

    fake_object_type = old_type
    fake_object_player = planet.Get_Owner()
    fake_object = {}
    fake_object.Get_Owner = fake_get_owner
    fake_object.Get_Type = fake_get_type
    fake_object.Get_Game_Scoring_Type = fake_get_type
    fake_object.Is_Valid = fake_is_valid
    Galactic_Unit_Destroyed_Event(fake_object, planet.Get_Final_Blow_Player())
end

--
-- This event is called when a planet changes faction in galactic mode
--
-- @param planet	      The planet object
-- @param newplayer		The new owner player of this planet.
-- @param oldplayer		The old owner player of this planet.
-- @since 6/20/2005 8:37:53 PM -- BMH
--
function Galactic_Planet_Faction_Change(planet, newplayer, oldplayer)
    crossplot:publish(
        "PLANET_OWNER_CHANGED",
        planet.Get_Type().Get_Name(),
        newplayer.Get_Faction_Name(),
        oldplayer.Get_Faction_Name()
    )
    -- Update the player table.
    Update_Player_Table(newplayer)
    Update_Player_Table(oldplayer)

    newid = newplayer.Get_ID()
    oldid = oldplayer.Get_ID()
    planet_type = planet.Get_Type()

    GameScoringMessage(
        "GameScoring -- %s changed control from %s to %s.",
        planet_type.Get_Name(),
        oldplayer.Get_Name(),
        newplayer.Get_Name()
    )

    -- Update the sacked count for the new owner.
    entry = GalacticConquestTable[newid]
    if entry == nil then
        entry = {}
    end

    pe = entry[planet_type]
    if pe == nil then
        pe = {sacked_count = 1, lost_count = 0}
    else
        pe.sacked_count = pe.sacked_count + 1
    end

    entry[planet_type] = pe
    GalacticConquestTable[newid] = entry

    -- Update the lost count for the old owner.
    entry = GalacticConquestTable[oldid]
    if entry == nil then
        entry = {}
    end

    pe = entry[planet_type]
    if pe == nil then
        pe = {sacked_count = 0, lost_count = 1}
    else
        pe.lost_count = pe.lost_count + 1
    end

    entry[planet_type] = pe
    GalacticConquestTable[oldid] = entry

    planet_type = nil
end

--
-- This event is called when a hero is neutralized by another hero in galactic mode
--
-- @param hero_type	The hero that was just neutralized
-- @param killer		The hero that just neutralized the above hero.
-- @since 3/21/2005 1:43:44 PM -- BMH
--
function Galactic_Neutralized_Event(hero_type, killer)
    Update_Player_Table(killer.Get_Owner())

    killer_id = killer.Get_Owner().Get_ID()

    entry = GalacticNeutralizedTable[killer_id]
    if entry == nil then
        entry = {}
    end

    pe = entry[hero_type]
    if pe == nil then
        pe = {neutralized = 1}
    else
        pe.neutralized = pe.neutralized + 1
    end

    entry[hero_type] = pe
    GalacticNeutralizedTable[killer_id] = entry
end

--
-- This function returns the number of frags a given player has for a given object type.
--
-- @param object_type        the object type we want to know about.
-- @param player             the player who's frag count we want to query.
-- @since 3/21/2005 1:23:21 PM -- BMH
--
function Get_Frag_Count_For_Type(object_type, player)
    owner_id = player.Get_ID()

    frag_entry = GalacticKillStatsTable[frag_index]
    if frag_entry == nil then
        return 0
    end

    entry = frag_entry[owner_id]
    if entry == nil then
        return 0
    end

    pe = entry[object_type]
    if pe == nil then
        return 0
    end

    return pe.kills
end

--
-- This function returns the number of neutralizes a given player has for a given object type.
--
-- @param object_type        the object type we want to know about.
-- @param player             the player who's neutralize count we want to query.
-- @since 3/21/2005 1:23:21 PM -- BMH
--
function Get_Neutralized_Count_For_Type(object_type, player)
    owner_id = player.Get_ID()

    entry = GalacticNeutralizedTable[owner_id]
    if entry == nil then
        return 0
    end

    pe = entry[object_type]
    if pe == nil then
        return 0
    end

    return pe.neutralized
end

function Get_Military_Efficiency(player, kill_stats, build_stats)
    pid = player.Get_ID()

    kill_eff = 0
    kill_table = kill_stats[frag_index][pid]

    tkills = 0
    tpower = 0
    tscore = 0
    if kill_table then
        for kk, vv in pairs(kill_table) do
            tkills = tkills + vv.kills
            tpower = tpower + vv.combat_power
            tscore = tscore + vv.score_value
        end
    end

    death_table = kill_stats[death_index][pid]

    tdeaths = 0
    tdpower = 0
    tdscore = 0
    if death_table then
        for kk, vv in pairs(death_table) do
            tdeaths = tdeaths + vv.kills
            tdpower = tdpower + vv.combat_power
            tdscore = tdscore + vv.score_value
        end
    end

    -- build stats
    build_count = 0
    cost_count = 0
    power_count = 0
    score_count = 0

    if build_stats[pid] then
        for planet_type, planet_entry in pairs(build_stats[pid]) do
            for object_type, type_entry in pairs(planet_entry) do
                build_count = build_count + type_entry.build_count
                cost_count = cost_count + type_entry.build_cost
                power_count = power_count + type_entry.combat_power
                score_count = score_count + type_entry.score_value
            end
        end
    end

    if tpower == 0 then
        kill_eff = 0
    elseif tdpower == 0 then
        kill_eff = tpower
    else
        kill_eff = tpower / tdpower
    end

    if build_count == 0 then
        if tdeaths == 0 then
            mill_eff = 0
        else
            mill_eff = -1
        end
    elseif tdeaths > build_count then
        mill_eff = -((tdeaths - build_count) / build_count)
    else
        mill_eff = (build_count - tdeaths) / build_count
    end

    return mill_eff, kill_eff
end

function Get_Conquest_Efficiency(player)
    pid = player.Get_ID()

    -- [playerid][planet_type][sacked_count, lost_count]
    entry = GalacticConquestTable[pid]

    if entry == nil then
        return 0
    end

    sacked = 0
    lost = 0
    for planet_type, pe in pairs(entry) do
        sacked = sacked + pe.sacked_count
        lost = lost + pe.lost_count
    end

    if sacked == 0 then
        conq_eff = 0
    elseif lost == 0 then
        conq_eff = sacked
    else
        conq_eff = sacked / lost
    end

    return conq_eff
end

function Calc_Score_For_Efficiency(eff_val)
    if eff_val > 1.0 then
        return 50000
    elseif eff_val > 0.98 then
        return 30000
    elseif eff_val > 0.94 then
        return 25000
    elseif eff_val > 0.91 then
        return 20000
    elseif eff_val > 0.88 then
        return 10000
    elseif eff_val > 0.84 then
        return 9000
    elseif eff_val > 0.80 then
        return 8000
    elseif eff_val > 0.78 then
        return 4000
    elseif eff_val > 0.74 then
        return 3000
    elseif eff_val > 0.70 then
        return 2000
    elseif eff_val > 0.60 then
        return 1000
    elseif eff_val > 0.50 then
        return 500
    elseif eff_val > 0.40 then
        return 400
    elseif eff_val > 0.30 then
        return 300
    elseif eff_val > 0.20 then
        return 200
    elseif eff_val > 0.10 then
        return 100
    else
        return 0
    end
end

function Define_Title_Faction_Table()
    -- rebel at 2, empire at 3
    Title_Faction_Table = {
        {145000, "TEXT_REBEL_TITLE19", "TEXT_EMPIRE_TITLE19"},
        {125000, "TEXT_REBEL_TITLE18", "TEXT_EMPIRE_TITLE18"},
        {115000, "TEXT_REBEL_TITLE17", "TEXT_EMPIRE_TITLE17"},
        {100000, "TEXT_REBEL_TITLE16", "TEXT_EMPIRE_TITLE16"},
        {90000, "TEXT_REBEL_TITLE15", "TEXT_EMPIRE_TITLE15"},
        {85000, "TEXT_REBEL_TITLE14", "TEXT_EMPIRE_TITLE14"},
        {80000, "TEXT_REBEL_TITLE13", "TEXT_EMPIRE_TITLE13"},
        {75000, "TEXT_REBEL_TITLE12", "TEXT_EMPIRE_TITLE12"},
        {70000, "TEXT_REBEL_TITLE11", "TEXT_EMPIRE_TITLE11"},
        {60000, "TEXT_REBEL_TITLE10", "TEXT_EMPIRE_TITLE10"},
        {55000, "TEXT_REBEL_TITLE9", "TEXT_EMPIRE_TITLE9"},
        {50000, "TEXT_REBEL_TITLE8", "TEXT_EMPIRE_TITLE8"},
        {45000, "TEXT_REBEL_TITLE7", "TEXT_EMPIRE_TITLE7"},
        {40000, "TEXT_REBEL_TITLE6", "TEXT_EMPIRE_TITLE6"},
        {25000, "TEXT_REBEL_TITLE5", "TEXT_EMPIRE_TITLE5"},
        {20000, "TEXT_REBEL_TITLE4", "TEXT_EMPIRE_TITLE4"},
        {15000, "TEXT_REBEL_TITLE3", "TEXT_EMPIRE_TITLE3"},
        {10000, "TEXT_REBEL_TITLE2", "TEXT_EMPIRE_TITLE2"},
        {5000, "TEXT_REBEL_TITLE1", "TEXT_EMPIRE_TITLE1"},
        {0, "TEXT_REBEL_TITLE0", "TEXT_EMPIRE_TITLE0"}
    }
end

function Debug_Print_Score_Vals()
    for pid, player in pairs(PlayerTable) do
        mill_eff, kill_eff = Get_Military_Efficiency(player, TacticalKillStatsTable, TacticalBuildStatsTable)

        score = Calc_Score_For_Efficiency(mill_eff)
        score = score + Calc_Score_For_Efficiency(kill_eff)

        if PlayerQuitTable[pid] == true then
            score = 0
        end

        GameScoringMessage(
            "Tactical %s:%s, Mill_Eff:%f, Kill_Eff:%f, Score:%f",
            player.Get_Name(),
            player.Get_Faction_Name(),
            mill_eff,
            kill_eff,
            score
        )
    end

    for pid, player in pairs(PlayerTable) do
        mill_eff, kill_eff = Get_Military_Efficiency(player, GalacticKillStatsTable, GalacticBuildStatsTable)
        conq_eff = Get_Conquest_Efficiency(player)

        score = Calc_Score_For_Efficiency(mill_eff)
        score = score + Calc_Score_For_Efficiency(kill_eff)
        score = score + Calc_Score_For_Efficiency(Get_Conquest_Efficiency(player))

        if PlayerQuitTable[pid] == true then
            score = 0
        end

        GameScoringMessage(
            "Galactic %s:%s, Mill_Eff:%f, Kill_Eff:%f, Conq_eff:%f, Score:%f",
            player.Get_Name(),
            player.Get_Faction_Name(),
            mill_eff,
            kill_eff,
            conq_eff,
            score
        )
    end
end
--
-- This function returns the a game stat for the given control id.
--
-- @param control_id         the control id
-- @return the game stat
-- @since 6/18/2005 4:13:13 PM -- BMH
--
function Get_Game_Stat_For_Control_ID(player, control_id, for_tactical)
    if for_tactical then
        mill_eff, kill_eff = Get_Military_Efficiency(player, TacticalKillStatsTable, TacticalBuildStatsTable)
    else
        mill_eff, kill_eff = Get_Military_Efficiency(player, GalacticKillStatsTable, GalacticBuildStatsTable)
    end

    if control_id == "IDC_MILITARY_EFFICIENCY_STATIC" then
        return mill_eff
    elseif control_id == "IDC_CONQUEST_EFFICIENCY_STATIC" then
        return Get_Conquest_Efficiency(player)
    elseif control_id == "IDC_KILL_EFFICIENCY_STATIC" then
        return kill_eff
    elseif control_id == "IDC_YOUR_LOSS_VAL_STATIC" or control_id == "IDC_ENEMY_LOSS_VAL_STATIC" then
        return Calc_Score_For_Efficiency(mill_eff) + Calc_Score_For_Efficiency(kill_eff)
    elseif control_id == "IDC_TITLE_STATIC" then
        score = Calc_Score_For_Efficiency(mill_eff)
        score = score + Calc_Score_For_Efficiency(kill_eff)
        score = score + Calc_Score_For_Efficiency(Get_Conquest_Efficiency(player))
        tid = 3
        if player.Get_Faction_Name() == "REBEL" then
            tid = 2
        end

        if PlayerQuitTable[player.Get_ID()] == true then
            score = 0
        end

        for ival, pe in ipairs(Title_Faction_Table) do
            last = pe[tid]
            if score > pe[1] then
                break
            end
        end
        return last
    else
        MessageBox("Unknown control id %s:%s for Get_Game_Stat_For_Control_ID", type(control_id), tostring(control_id))
    end
end

--
-- This function updates the table of GameSpy game stats.
--
-- @since 3/29/2005 5:14:42 PM -- BMH
--
function Update_GameSpy_Game_Stats()
end

--
-- This function updates the table of GameSpy player kill stats.
--
-- @param stat_table		the stat table we should pull stats from
-- @param player			the player who's stats we need to update.
-- @since 3/29/2005 5:14:42 PM -- BMH
--
function Update_GameSpy_Kill_Stats(stat_table, build_stats, player)
end

--
-- This function updates the table of GameSpy player stats.
--
-- @param player		the player who's stats we need to update.
-- @since 3/29/2005 5:14:42 PM -- BMH
--
function Update_GameSpy_Player_Stats(player)
end

function Get_Current_Winner_By_Score()
    return WinnerID
end
