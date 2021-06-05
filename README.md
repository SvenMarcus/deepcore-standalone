![](DeepCore.png)

- [The Deep Core Modding Framework](#the-deep-core-modding-framework)
  - [Introduction](#introduction)
  - [License](#license)
  - [Installation](#installation)
  - [Quick Reference](#quick-reference)
    - [Plugin folders](#plugin-folders)
    - [Skeleton of a plugin definition](#skeleton-of-a-plugin-definition)
    - [Skeleton of a plugin class](#skeleton-of-a-plugin-class)
    - [Builtin plugin targets](#builtin-plugin-targets)
    - [The GalacticConquest class](#the-galacticconquest-class)
      - [Attributes](#attributes)
      - [Methods](#methods)
      - [Events](#events)
    - [The Planet class](#the-planet-class)
  - [Overview over the included example plugins](#overview-over-the-included-example-plugins)
    - [Galactic](#galactic)
    - [Tactical](#tactical)
      - [Space](#space)
  - [Basic set up](#basic-set-up)
    - [Using the framework in Galactic Conquest](#using-the-framework-in-galactic-conquest)
    - [Using the framework with a game object script](#using-the-framework-with-a-game-object-script)
    - [Creating a plugin definition](#creating-a-plugin-definition)
    - [Implementing a plugin object](#implementing-a-plugin-object)
    - [Using the events from the GalacticConquest object](#using-the-events-from-the-galacticconquest-object)
    - [Defining a plugin with dependencies](#defining-a-plugin-with-dependencies)
  - [Using eawx-crossplot for communication between story plots](#using-eawx-crossplot-for-communication-between-story-plots)

# The Deep Core Modding Framework

This repository contains the source files for a standalone mod version of the Deep Core Framework. The framework was developed for Empire at War Expanded and powers most of its core features.

## Introduction

When adding more and more Lua based features to an Empire at War mod the number of modules that need to be updated every frame grows. Moreover managing dependencies and wiring the whole system together becomes increasingly complex.
To combat this complexity we have introduced a framework that comes with a plugin system that loads modules from a plugin folder, resolves their specified dependencies automatically and updates them at a set time during the update cycle. Additionally it also includes a class system as well as crossplot, a powerful library to communicate across different story plots in EaW. The following sections explain its functionality in detail. If you just want to have quick look jump to the [Quick Reference](#quick-reference)

This repository also includes a fix for a bug regarding using the `require` function in scripts attached to game objects in the `PGBase.lua` file.

## License

This project uses the [MIT License](LICENSE)

## Installation

This mod can be used as a base mod for other projects. To make the setup easier it is also released at the Steam Workshop.

If you want to install from this repostitory directly, drop the `Data/Scripts/Library/deepcore` directory into your mod's `Data/Scripts/Library` folder. Override the default `GameScoring.lua` in `Data/Scripts/Miscellaneous` and `PGBase.lua` in `Data/Scripts/Library` with the ones provided in this repository.

## Quick Reference

### Plugin folders

The parent plugin folder is specified in a configuration table that gets passed to DeepCore initializer functions (e.g. `deepcore:galactic { plugin_folder = "my_plugin_folder"}`). 
Plugins are folders inside the parent folder that contain at least a file called `init.lua` that returns a plugin definition as specified in the following section.

### Skeleton of a plugin definition

```lua
require("deepcore/std/plugintargets")
require("eawx-plugins/my-plugin/MyPlugin")

return {
    target = PluginTargets.always(),
    requires_planets = false,
    dependencies = { "another-plugin" },
    init = function(self, ctx, the_other_plugin)
        return MyPlugin(the_other_plugin)
    end
}
```

### Skeleton of a plugin class

```lua
require("deepcore/std/class")

---@class MyPlugin
MyPlugin = class()

function MyPlugin:new(args)
    self.args = args
end

function MyPlugin:update()

end
```

### Builtin plugin targets

| Name       | Parameters            | Description                                                                   |
| ---------- | --------------------- | ----------------------------------------------------------------------------- |
| always     | -                     | Allows a plugin to be updated every frame                                     |
| never      | -                     | Never allows updates. Use this if you want to react to observable events only |
| interval   | number                | Updates the plugin every X seconds                                            |
| story_flag | string, PlayerWrapper | Uses `Check_Story_Flag` to determine if an update is allowed                  |

### The GalacticConquest class

#### Attributes

| Attribute   | Type                      | Description                            |
| ----------- | ------------------------- | -------------------------------------- |
| HumanPlayer | PlayerWrapper             | The human player                       |
| Planets     | table<string, Planet>     | Key: Planet name, Value: Planet object |
| Events      | table<string, Observable> | Key: Event name, Value: Event object   |


#### Methods

| Method                                          | Return type           | Description                              |
| ----------------------------------------------- | --------------------- | ---------------------------------------- |
| get_all_planets_by_faction(faction)             | table<string, Planet> | Key: Planet name, Value: Planet object   |
| get_number_of_planets_owned_by_faction(faction) | number                | Number of planets owned by given faction |


#### Events

| Event name                 | Event Args for listeners | Arg Description                            |
| -------------------------- | ------------------------ | ------------------------------------------ |
| PlanetOwnerChanged         | Planet                   | -                                          |
| GalacticProductionStarted  | Planet, string           | The string represents the object type name |
| GalacticProductionFinished | Planet, string           | The string represents the object type name |
| GalacticProductionCanceled | Planet, string           | The string represents the object type name |
| GalacticHeroKilled         | string                   | The hero type name                         |
| TacticalBattleStarting     | -                        | -                                          |
| TacticalBattleEnding       | -                        | -                                          |


### The Planet class

EawX wraps EaW's planet objects in a custom `Planet` class. `ctx.galactic_conquest.Planets` as well as planets received from its events are all instances of the `Planet` class.

| Methods                              | Return type       |
| ------------------------------------ | ----------------- |
| Planet:get_owner()                   | PlayerWrapper     |
| Planet:get_game_object()             | GameObjectWrapper |
| Planet:get_name()                    | string            |
| Planet:has_structure(structure_name) | boolean           |

## Overview over the included example plugins

### Galactic

- production-listener: A plugin that refunds the cost of a unit upon construction. Demonstrates how to use the events of the `GalacticConquest` class.
- weekly-game-message-service: A plugin that shows a pop up message depending on the amount of produced objects. Demonstrates how to use plugin dependencies.
- weekly-kuat-flip: Flips the affiliation of Kuat between the Empire and the Rebels every week. 
- ui-listener: Shows a pop up message when the player clicks the credit filter on the commandbar in galactic mode. Demonstrates the `story_flag` plugin target.

### Tactical 

#### Space

- microjump: An ability that teleports a unit to a given position using the weaken enemy ability. It is attached to the Tartan Cruiser. Unlike the other included plugins this is not just an example, but a fully usable ability and is also used in Empire at War Expanded: Thrawns Revenge.

## Basic set up
### Using the framework in Galactic Conquest

A single story plot in a GC should be set as the container for the EawX Framework. A high `ServiceRate` must be set (we use 0.1) in order to ensure that all plugins will receive updates at the correct time. Calling `deepcore:galactic` will load plugins from the folder specified in the configuration table and return a plugin runner that is responsible for continuously updating your plugins. Additionally a `context` table that can include variables you want to pass to every plugin `init()` function and a list of plugin folders may be provided inside the configuration table. If no plugin folder list is given the plugin system will load the file `InstalledPlugins.lua` from the specified plugin folder.

<details>
  <summary>Click to see the main GC Lua file</summary>

```lua
require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("deepcore/std/deepcore")

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

        DeepCoreRunner = deepcore:galactic {
            context = context,
            plugin_folder = "eawx-plugins/galactic"
        }
    elseif message == OnUpdate then
        DeepCoreRunner:update()
    end
end

```
</details>

### Using the framework with a game object script

The framework isn't limited to Galactic Conquest. You can also use it from a game object script. Similar to galactic mode you can call `deepcore:game_object()` with a configuration table to load plugins and create a plugin runner. Just like `deepcore:galactic()` you can provide optional `context` and `plugins` tables. It is intended to be used during tactical mode only.

<details>
  <summary>Click to see the game object Lua file</summary>

```lua
require("PGCommands")
require("PGStateMachine")
require("deepcore/std/deepcore")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    Define_State("State_Init", State_Init)
end

function State_Init(message)
    if message == OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end

        DeepCoreRunner = deepcore:game_object {
            context = {},
            plugin_folder = "eawx-plugins/gameobject/space",
            plugins = { "microjump" }
        }
    elseif message == OnUpdate then
        DeepCoreRunner:update()
    end
end
```
</details>


### Creating a plugin definition

A plugin consists of a folder containing at least a file called `init.lua`. It is used to configure and create the plugin object. The `init.lua` must return a table with both `target` and `init` keys. The `target` specifies *when* or *how often* a plugin gets updated. The targets are defined in `plugintargets.lua` and can be extended with new targets if needed. `init` refers to a function that must at least be able to receive the `self` argument. Its second argument is the plugin `context` (`ctx`) table that was defined in the main GC or game object Lua function (see [Using the framework in Galactic Conquest](#using-the-framework-in-galactic-conquest) and [Using the framework with a game object script](#using-the-framework-with-a-game-object-script)). If you're defining a galactic conquest plugin the `ctx` table contains the `GalacticConquest` object in `ctx.galactic_conquest`. See [The GalacticConquest class](#the-galacticconquest-class) for more information on what functions it provides. The `init` function must return a plugin object with an `update` function (unless the target is `never()`).
Galactic conquest plugins can set the `requires_planets` to `true`. In that case the plugin's update function will be called with one planet at a time.

The code snippet below demonstrates the structure of the `init.lua` file.

<details>
  <summary>Click to see init.lua of production-listener</summary>

```lua
require("deepcore/std/plugintargets")
require("eawx-plugins/galactic/production-listener/ProductionFinishedListener")

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

| Name       | Parameters            | Description                                                                   |
| ---------- | --------------------- | ----------------------------------------------------------------------------- |
| always     | -                     | Allows a plugin to be updated every frame                                     |
| never      | -                     | Never allows updates. Use this if you want to react to observable events only |
| interval   | number                | Updates the plugin every X seconds                                            |
| story_flag | string, PlayerWrapper | Uses `Check_Story_Flag` to determine if an update is allowed                  |


### Implementing a plugin object

As specified in the previous section most plugin objects require an `update` function. Plugin objects can be created using a simple table inside the plugin definition:

<details>
  <summary>Click to see a simple table with an update function</summary>

```lua
require("deepcore/std/plugintargets")

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

They can also be objects located in another file like the `ProductionFinishedListener` from the previous section. The next section about events will show its code in more detail. To enhance readability and code structure it is recommended to place plugin objects in separate files.


### Using the events from the GalacticConquest object

The following example demonstrates how to listen to the events defined in the `GalacticConquest` object. As explained in the first plugin definition, the `GalacticConquest` object gets passed to a plugin's `init()` function via the `context` table. From there it can be accessed with `ctx.galactic_conquest`. The events are defined inside a sub-table of the object and can be accessed with `ctx.galactic_conquest.Events`. The `production-listener` plugin uses the `GalacticProductionFinished` event to count the total amount of objects produced by the player and return the build cost of the produced object. To do that it attaches its own function `on_production_finished` with the additional argument `self` to the event via `attach_listener()`.

<details>
  <summary>Click to see the ProductionFinishedListener plugin</summary>

```lua
require("deepcore/std/class")

---@class ProductionFinishedListener
ProductionFinishedListener = class()

---@param galactic_conquest GalacticConquest
function ProductionFinishedListener:new(galactic_conquest)
    self.human_player = galactic_conquest.HumanPlayer
    self.total_amount_of_objects = 0
    galactic_conquest.Events.GalacticProductionFinished:attach_listener(self.on_production_finished, self)
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
require("deepcore/std/plugintargets")
require("eawx-plugins/galactic/weekly-game-message-service/GameMessageService")

return {
    target = PluginTargets.interval(45),
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
require("deepcore/std/class")

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

require("deepcore/crossplot/crossplot")

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

require("deepcore/crossplot/crossplot")

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


