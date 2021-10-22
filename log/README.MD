# eaw-log

A logging framework for Star Wars: Empire at War and Star Wars: Empire at War: Forces of Corruption

## Installation

Drop the provided scripts directory into your `mod/data` directory. That's it.

## Usage

The framework splits the logging into the logger (the thing you usually call
within your code to log a message) and the sink (the part that takes care of
the actual output).

You can create a logger instance with a single call:

```lua
my_logger = require("eaw-log/logger")
```

This instance comes with reasonable defaults and a default file sink pre-configured.
Currently the file sink is the only supported logging mechanism and outputs all logged messages to a specific log file (default: `eaw-lua.log`)

## Logging

The logger provides the following logging methods. Let's assume the logger instance is called `my_logger` and was created as described above.

```lua
my_logger:trace("A trace message.")
my_logger:info("An info message.")
my_logger:warn("A warning message.")
my_logger:error("An error message.")
```

Each method can also be called with a formatting string and an arbitrary amount of additional arguments:

```lua
my_logger:trace("A message from %s with a nice floating point number %f.", "Darth Vader", 2.344)
```

Depending on the object you pass, you may have to explicitly call `tostring()` on the argument. This is usually necessary for non-native data types, e.g. `GameObjects`, etc.

```lua
local my_object = {my = 3, complicated = 4, object = "test"}
my_logger:trace("A message from %s with a nice floating point number %f and my complicated object %s", "Darth Vader", 2.344, tostring(object))
```

## Configuration

The logger provides several configuration methods that allow chaining:

### Log Level

Log levels range between 0 and 3, default is 2.

|Log Level|Explanation|
|:---:|:---|
| 0 | Only error messages will be logged.|
| 1 | Only error and warning messages will be logged.|
| 2 | Error, warning, and information messages will be logged.|
| 3 | Error, warning, information, and debug trace messages will be logged.|

```lua
my_logger = require("eaw-log/logger"):with_log_level(1)
```

### Logger with Custom Sink

```lua
my_logger = require("eaw-log/logger"):with_sink("file")
```

`with_sink()` either accepts a string that represents the name of a file in the `eaw-log/sinks/` directory, or a preconfigured sink.

### Example

```lua
my_customized_logger =
    require("eaw-log/logger")
    :with_sink(require("eaw-log/sinks/file")
        :with_target_file("my_log_file.txt"))
    :with_log_level(3)
```

This will create a logger (`require("eaw-log/logger")`) that logs all log messages from errors to traces (`:with_log_level(3)`) to the file `"my_log_file.txt"` (`:with_sink(require("eaw-log/sinks/file"):with_target_file("my_log_file.txt"))`)

## Adding Sinks

You can add sinks by adding them to the `eaw-log/sinks/` directory.
### Requirements/Sink API

A valid sink must fulfill the following rules:

* The sink is a valid table.
* The sink provides a function `sink.__log(self: table, message: string)`
* The sink has a property `sink.__id` of type `string` that contains the name of the file without the `.lua` file ending.
* The sink has a property `sink.__has_character_limit` of type `bool` that is true if the target has a character limit (e.g. the `Game_Message(message: string)` function.) This will omit the call stack in from the log level `ERROR`.

See the `eaw-log/sinks/file.lua` and `eaw-log/sinks/droid-log.lua` as an example.

----

## Available Sinks

### Sink: File (Recommended)

A sink that logs to the base game's AI log and a configurable file.

#### Caveats

* Only useful with the EaW/FoC debug build.

### Sink: Droid Log

A sink that logs to the game's droid advisor popup and subsequent message log.

#### Caveats

* Only useful with the latest EaW/FoC Steam version.
* If the log exceeds a (currently unknown) character limit the game will crash to desktop.
* The log messages may not appear in order of creation in the script.
* The log messages may overwhelm the droid log.

----

## Changelog

### 2021-01-18 - 2.0.0

* **Features**
    * New Sink: Droid Log
* **Changes**
    * **[BREAKING CHANGE]** Sink API Updated to include `sink.__id` and `sink.__has_character_limit` properties.

### 2020-06-09 - 1.0.0

* **Features**
    * Initial release
