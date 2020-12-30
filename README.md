- [The EawX Galactic Framework](#the-eawx-galactic-framework)
  - [Introduction](#introduction)
  - [License](#license)
  - [Installation](#installation)
  - [Basic set up](#basic-set-up)
    - [Using the framework in Galactic Conquest](#using-the-framework-in-galactic-conquest)
    - [Using the framework with a game object script](#using-the-framework-with-a-game-object-script)
    - [Creating a plugin definition](#creating-a-plugin-definition)
    - [Implementing a plugin object](#implementing-a-plugin-object)
    - [Using the events from the GalacticConquest object](#using-the-events-from-the-galacticconquest-object)
    - [Defining a plugin with dependencies](#defining-a-plugin-with-dependencies)
  - [Using eawx-crossplot for communication between story plots](#using-eawx-crossplot-for-communication-between-story-plots)
  - [The GalacticConquest class](#the-galacticconquest-class)
    - [Attributes](#attributes)
    - [Methods](#methods)
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

This project uses the [MIT License](LICENSE)

## Installation

Drop the `eawx-` directories into your mod's `Data/Scripts/Library` folder. Override the default `GameScoring.lua` in `Data/Scripts/Miscellaneous` with the one provided in this repository.

## Basic set up
### Using the framework in Galactic Conquest

A single story plot in a GC should be set as the container for the EawX Framework. A high `ServiceRate` must be set (we use 0.1) in order to guarantee that all plugins will receive updates at the correct time. The `EawXMod` object that loads and updates your plugins can be instantiated without any arguments or with a `context` table that can include variables you want to pass to every plugin `init()` function and a plugin folder list. If no plugin folder list is specified the plugin system will load the file `eawx-plugins/InstalledPlugins.lua`.

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
        -- The context table allows you to pass variables to
        -- the init() function of your plugins
        local context = {}

        ActiveMod = EawXMod(context)
    elseif message == OnUpdate then
        ActiveMod:update()
    end
end
```
</details>

### Using the framework with a game object script

The framework isn't limited to Galactic Conquest. You can also use it from a game object script. Instead of using `EawXMod` the game object script requires an instance of `EawXGameObject`. Just like with `EawXMod` the `EawXGameObject` class can be instantiated with optional `context` and `installed_plugins` tables. It is intended to be used during tactical mode only.

```lua
require("PGDebug")
require("PGStateMachine")

require("eawx-std/EawXGameObject")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.1

    Define_State("Game_Object_Main", Game_Object_Main)
end

function Game_Object_Main(message)
    if message == OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end

        GameObject = EawXGameObject(context)
    elseif message == OnUpdate then
        GameObject:update()
    end
end
```
</details>


### Creating a plugin definition

Plugins for galactic conquest must be placed inside the `eawx-plugins` directory. Plugins for game objects are placed in the `eawx-plugins-gameobject-space` and `eawx-plugins-gameobject-land` directories. The `PluginLoader` will automatically determine the required directory based on the current game mode. 

A plugin consists of a folder containing at least a file called `init.lua`. It is used to configure and create the plugin object. The `init.lua` must return a table with both `target` and `init` keys. The `target` specifies *when* or *how often* a plugin gets updated. The targets are defined in `plugintargets.lua` and can be extended with new targets if needed. `init` refers to a function that must at least be able to receive the `self` argument. Its second argument is the plugin `context` (`ctx`) table that was defined in the main GC or game object Lua function (see [Using the framework in Galactic Conquest](#using-the-framework-in-galactic-conquest) and [Using the framework with a game object script](#using-the-framework-with-a-game-object-script)). If you're defining a galactic conquest plugin the `ctx` table contains the `GalacticConquest` object in `ctx.galactic_conquest`. See [The GalacticConquest class](#the-galacticconquest-class) for more information on what functions it provides. The `init` function must return a plugin object with an `update` function (unless the target is `never()`).
Galactic conquest plugins can set the `requires_planets` to `true`. In that case the plugin's update function will be called with one planet at a time.

The code snippet below demonstrates the structure of the `init.lua` file.

<details>
  <summary>Click to see init.lua of production-listener</summary>

```lua
require("eawx-std/plugintargets")
require("eawx-plugins/production-listener/ProductionFinishedListener")

return {
    target = PluginTargets.never(),
    requires_planets = false,
    init = function(self, ctx)
        ---@type GalacticConquest
        local galactic_conquest = ctx.galactic_conquest

        return ProductionFinishedListener(galactic_conquest)
    end
}
```
</details>

The framework comes with the following plugin targets out of the box:

| Name       | Parameters           | Description                                                                   |
| ---------- | -------------------- | ----------------------------------------------------------------------------- |
| always     | -                    | Allows a plugin to be updated every frame                                     |
| never      | -                    | Never allows updates. Use this if you want to react to observable events only |
| interval   | number               | Updates the plugin every X seconds                                            |
| story_flag | string, PlayerObject | Uses `Check_Story_Flag` to determine if an update is allowed                  |


### Implementing a plugin object

As specified in the previous section most plugin objects require an `update` function. Plugin objects can be created using a simple table inside the plugin definition:

<details>
  <summary>Click to see a simple table with an update function</summary>

```lua
require("eawx-std/plugintargets")

return {
    target = PluginTargets.interval(45)
    init = function(self, ctx)
        return {
            update = function(self)
                -- do something
            end
        }
    end
}
```
</details>

They can also be objects located in another file like the `ProductionFinishedListener` from the previous section. The next section about events will show its code in more detail. To enhance readability and code structure I recommend placing plugin objects in separate files.


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

The EawX framework comes with `crossplot`, a library that allows publish-subscribe communication via `GlobalValues` between story plots. To achieve this `crossplot` initialises a `MasterGlobalValueEventBus` in `GameScoring.lua` that listens to incoming subscriptions and publish messages. The publish messages are redirected to `GlobalValueEventBus` instances running on different story plots. Users of `crossplot` don't have to worry about the implementation details and can simply call `crossplot:galactic()` to initialise `crossplot` in a galactic story plot. The story plot running the instance of `EawXMod` does not have to call `crossplot:galactic()` explicitly, it will be initialised inside the `EawXMod` constructor and can be used globally afterwards.

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
        crossplot:galactic()
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
        crossplot:galactic()
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


### Methods

| Method                                          | Return type           | Description                              |
| ----------------------------------------------- | --------------------- | ---------------------------------------- |
| get_all_planets_by_faction(faction)             | table<string, Planet> | Key: Planet name, Value: Planet object   |
| get_number_of_planets_owned_by_faction(faction) | number                | Number of planets owned by given faction |


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
