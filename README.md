- [The EawX Galactic Framework](#the-eawx-galactic-framework)
  - [Introduction](#introduction)
  - [License](#license)
  - [Installation](#installation)
  - [Basic set up](#basic-set-up)
    - [The main GC Lua file](#the-main-gc-lua-file)
    - [Defining a plugin](#defining-a-plugin)
    - [Using the events from the GalacticConquest object](#using-the-events-from-the-galacticconquest-object)
    - [Defining a plugin with dependencies](#defining-a-plugin-with-dependencies)
  - [Using eawx-crossplot for communication between story plots](#using-eawx-crossplot-for-communication-between-story-plots)
  - [The GalacticConquest class](#the-galacticconquest-class)
      - [Attributes](#attributes)
      - [Events](#events)
  - [The Planet class](#the-planet-class)
  - [Quick Reference](#quick-reference)
      - [Plugin folders](#plugin-folders)
      - [Skeleton of a plugin definition](#skeleton-of-a-plugin-definition)
      - [Skeleton of a plugin class](#skeleton-of-a-plugin-class)
      - [Possible plugin targets](#possible-plugin-targets)

# The EawX Galactic Framework

This repository contains the source files of the Empire at War Expanded Galactic Framework. It can be launched as a mod to demonstrate basic functionality.

## Introduction

When adding more and more Lua based features to an Empire at War mod the number of modules that need to be updated every frame grows. Moreover managing dependencies and wiring the whole system together becomes increasingly complex.
To combat this complexity we have introduced a framework that comes with a plugin system that loads modules from a plugin folder, resolves their specified dependencies automatically and updates them at a set time during the update cycle. Additionally it also includes a class system as well as crossplot, a powerful library to communicate across different story plots in EaW. The following sections explain its functionality in detail. If you just want to have quick look jump to the [Quick Reference](#quick-reference)

## License

You are free to use the framework in other Empire at War mods on the condition that the `eawx-` folder names and the names of the contained files are not changed. Moreover proper credits must be given in the mod's Readme.

## Installation

Drop the `eawx-` directories into your mod's `Data/Scripts/Library` folder. Override the default `GameScoring.lua` in `Data/Scripts/Miscellaneous` with the one provided in this repository.

## Basic set up
### The main GC Lua file

A single story plot in a GC should be set as the container for the EawX Framework. A high `ServiceRate` must be set (we use 0.1) in order to guarantee that all plugins will receive updates at the correct time. To instantiate the `EawXMod` object that loads and updates your plugins you will at least need to pass a list of playable factions into its constructor function. Additional optional arguments are a `context` table that can include variables you want to pass to every plugin `init()` function and a plugin folder list. If no plugin folder list is specified the plugin system will load the file `eawx-plugins/InstalledPlugins.lua`.

<details>
  <summary>Click to see the main GC Lua file</summary>

```lua
require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("eawx-std/EawXMod")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.1

    StoryModeEvents = {Universal_Story_Start = Begin_GC}
end

function Begin_GC(message)
    if message == OnEnter then
        -- We need a list of playable factions for the GalacticConquest
        -- object instantiated in EawXMod
        local playable_factions = {
            "EMPIRE",
            "REBEL",
            "UNDERWORLD"
        }

        -- The context table allows you to pass variables to
        -- the init() function of your plugins
        local context = {}

        ActiveMod = EawXMod(playable_factions, context)
    elseif message == OnUpdate then
        ActiveMod:update()
    end
end
```
</details>

### Defining a plugin

All plugins must be specified in folders inside the `eawx-plugins` directory. They must include a file called `init.lua` that returns the instantiated plugin object.

The `init()` function must at least be able to receive the `self` argument. The `ctx` argument refers to the `context` table that was defined in the main GC Lua file. It will be passed to the `init()`  function when the plugin loader initialises the plugin. `galactic_conquest` is an object provided by the EawX framework that contains a list of planets in the GC, the human player object and several observable events. It will be added to the `context` table automatically. 

The `target` entry in the plugin definition specifies at when the plugin will be updated. In the following example the `target` is passive, meaing the plugin does not expect to updated explicitly.

After defining a plugin make sure to add them to the list in `InstalledPlugins.lua`.

<details>
  <summary>Click to see init.lua of production-listener</summary>

```lua
require("eawx-plugins/production-listener/ProductionFinishedListener")

return {
    -- The "passive" target means we don't expect to be updated
    target = "passive",
    init = function(self, ctx)
        ---@type GalacticConquest
        local galactic_conquest = ctx.galactic_conquest

        return ProductionFinishedListener(galactic_conquest)
    end
}
```
</details>

### Using the events from the GalacticConquest object

The following example demonstrates how to listen to the events defined in the `GalacticConquest` object. As explained in the first plugin definition, the `GalacticConquest` object gets passed to a plugin's `init()` function via the `context` table. From there it can be accessed with `ctx.galactic_conquest`. The events are defined inside a sub-table of the object and can be accessed with `ctx.galactic_conquest.Events`. The `production-listener` plugin uses the `GalacticProductionFinished` to count the total amount of objects produced by the player and return the build cost of the produced object. To do that it attaches its own function `on_production_finished` with the additional argument `self` to the event via `AttachListener()`.

<details>
  <summary>Click to see the ProductionFinishedListener plugin</summary>

```lua
require("eawx-std/class")

---@class ProductionFinishedListener
ProductionFinishedListener = class()

---@param galactic_conquest GalacticConquest
function ProductionFinishedListener:new(galactic_conquest)
    self.human_player = galactic_conquest.HumanPlayer
    self.total_amount_of_objects = 0
    galactic_conquest.Events.GalacticProductionFinished:AttachListener(self.on_production_finished, self)
end

---We don't like to lose money, so we return it to the player on build completion
---@param planet Planet
---@param object_type_name string
function ProductionFinishedListener:on_production_finished(planet, object_type_name)
    if not planet:get_owner().Is_Human() then
        return
    end

    self.total_amount_of_objects = self.total_amount_of_objects + 1

    local object_type = Find_Object_Type(object_type_name)
    if object_type then
        local cost = object_type.Get_Build_Cost()
        self.human_player.Give_Money(cost)
    end
end
```
</details>

### Defining a plugin with dependencies

Dependencies can be added to a plugin by providing a `dependencies` table in the plugin definition. The table contains a list of plugin folder names.

The plugin in the example below depends on the previously defined `production-listener` plugin. The plugin loader will initialise the dependencies of a plugin first and then pass the initialised dependencies to the plugin's `init()` function in the same order as specified in the `dependencies` table. In this case this means the `init()` function will receive an instance of `ProductionFinishedListener`.

**Important**: Plugin dependencies **must not** be cyclic. If a plugin `A` depends on plugin `B`, `B` depends on `C` and `C` depends on `A` the plugin loader will stop loading and likely break the GC script.

Another difference to the `production-listener` plugin is that in this case we use a `target` called `weekly-update`. This means the plugin will receive updates once at the beginning of a new week. Therefore it must implement an `update()` function.

<details>
  <summary>Click to see init.lua of weekly-game-message-service</summary>

```lua
require("eawx-plugins/weekly-game-message-service/GameMessageService")

return {
    -- weekly-update gets updated every week. This also means we have to implement an "update()" function!
    target = "weekly-update",
    -- We can specify plugin dependencies in this table
    dependencies = {"production-listener"},
    -- The plugins we specified in the dependencies table will be passed to the init function in order
    init = function(self, ctx, production_finished_listener)
        return GameMessageService(production_finished_listener)
    end
}
```
</details>

<details>
  <summary>Click to see the GameMessageService plugin</summary>

```lua
require("eawx-std/class")

---@class GameMessageService
GameMessageService = class()

---@param production_finished_listener ProductionFinishedListener
function GameMessageService:new(production_finished_listener)
    self.production_finished_listener = production_finished_listener
end

-- We'll show a Game_Message for every produced object
function GameMessageService:update()
    local objects_produced = self.production_finished_listener.total_amount_of_objects

    for i = 1, objects_produced do
        Game_Message("TEXT_FACTION_EMPIRE")
    end
end
```
</details>

## Using eawx-crossplot for communication between story plots

The EawX framework comes with `crossplot`, a library that allows publish-subscribe communication via `GlobalValues` between story plots. To achieve this `crossplot` initialises a `MasterGlobalValueEventBus` in `GameScoring.lua` that listens to incoming subscriptions and publish messages. The publish messages are redirected to `GlobalValueEventBus` instances running on different story plots. Users of `crossplot` don't have to worry about the implementation details and can simply call `crossplot:init()` to initialise `crossplot` in a story plot. The story plot running the instance of `EawXMod` does not have to call `crossplot:init()` explicitly, it will be initialised inside the `EawXMod` constructor and can be used globally afterwards.

The example below shows how the first plot subscribes to the `sub_test` event with its `Receive` function with `crossplot:subscribe()`. 
The second plot uses `crossplot:publish()` to publish an update to the `sub_test` event. The additional second argument provided by this plot will be passed on to the `Receive` function in the first plot. The number of additional arguments is not limited.

<details>
  <summary>Click to see Rebel plot</summary>

```lua
require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("eawx-crossplot/crossplot")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.1

    StoryModeEvents = {Universal_Story_Start = Begin_GC}
end

function Begin_GC(message)
    if message == OnEnter then
        crossplot:init()
        crossplot:subscribe("sub_test", Receive)
    elseif message == OnUpdate then
        crossplot:update()
    end
end

function Receive(text_entry)
    Game_Message(text_entry)
end
```
</details>

<details>
  <summary>Click to see Empire plot</summary>

```lua
require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("eawx-crossplot/crossplot")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.1

    StoryModeEvents = {Universal_Story_Start = Begin_GC}
end

function Begin_GC(message)
    if message == OnEnter then
        crossplot:init()
        Sleep(1) -- sleep to make sure the other plot had time to subscribe
        crossplot:publish("sub_test", "TEXT_FACTION_EMPIRE")
    elseif message == OnUpdate then
        crossplot:update()
    end
end
```
</details>

## The GalacticConquest class

### Attributes

| Attribute   | Type                      | Description                            |
| ----------- | ------------------------- | -------------------------------------- |
| HumanPlayer | PlayerWrapper             | The human player                       |
| Planets     | table<string, Planet>     | Key: Planet name, Value: Planet object |
| Events      | table<string, Observable> | Key: Event name, Value: Event object   |

### Events

| Event name                 | Event Args for listeners | Arg Description                            |
| -------------------------- | ------------------------ | ------------------------------------------ |
| PlanetOwnerChanged         | Planet                   | -                                          |
| GalacticProductionStarted  | Planet, string           | The string represents the object type name |
| GalacticProductionFinished | Planet, string           | The string represents the object type name |
| GalacticProductionCanceled | Planet, string           | The string represents the object type name |
| GalacticHeroKilled         | string                   | The hero type name                         |
| TacticalBattleStarting     | -                        | -                                          |
| TacticalBattleEnding       | -                        | -                                          |

## The Planet class

EawX wraps EaW's planet objects in a custom `Planet` class. `ctx.galactic_conquest.Planets` as well as planets received from its events are all instances of the `Planet` class.

| Methods                              | Return type       |
| ------------------------------------ | ----------------- |
| Planet:get_owner()                   | PlayerWrapper     |
| Planet:get_game_object()             | GameObjectWrapper |
| Planet:get_name()                    | string            |
| Planet:has_structure(structure_name) | boolean           |

## Quick Reference

### Plugin folders

All plugin must be located in the `eawx-plugins` directory. They also need to contain a file called `init.lua` that returns a plugin definition as specified in the following section.

### Skeleton of a plugin definition

```lua
require("eawx-plugins/my-plugin/MyPlugin")

return {
    target = "frame-update",
    init = function(self, ctx)
        return MyPlugin()
    end
}
```

### Skeleton of a plugin class

```lua
require("eawx-std/class")

---@class MyPlugin
MyPlugin = class()

function MyPlugin:new(args)
    self.args = args
end

function MyPlugin:update()

end
```


### Possible plugin targets

| target               | update time   | needs update method | update arguments |
| -------------------- | ------------- | ------------------- | ---------------- |
| passive              | never         | no                  | -                |
| frame-update         | OnUpdate      | yes                 | -                |
| frame-planet-update  | OnUpdate      | yes                 | planet           |
| weekly-update        | once per week | yes                 | -                |
| weekly-planet-update | once per week | yes                 | planet           |

**Note:** Targets containing `planet` run inside a loop over all planets in the GC. Every planet will be passed individually to the `update()` function.
