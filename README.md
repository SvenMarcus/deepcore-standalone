![](DeepCore.png)

# The Deep Core Modding Framework

This repository contains the source files for a standalone mod version of the Deep Core Framework. The framework was developed for Empire at War Expanded and powers most of its core features.

## Introduction

When adding more and more Lua based features to an Empire at War mod the number of modules that need to be updated every frame grows. Moreover managing dependencies and wiring the whole system together becomes increasingly complex.
To combat this complexity we have introduced a framework that comes with a plugin system that loads modules from a plugin folder, resolves their specified dependencies automatically and updates them at a set time during the update cycle. Additionally it also includes a class system as well as crossplot, a powerful library to communicate across different story plots in EaW. For detailed usage instructions have a look at the [wiki](https://github.com/SvenMarcus/deepcore-standalone/wiki).

This repository also includes a fix for a bug regarding using the `require` function in scripts attached to game objects in the `PGBase.lua` file.

## License

This project uses the [MIT License](LICENSE)

## Installation

This mod can be used as a base mod for other projects. To make the setup easier it is also released at the Steam Workshop.

If you want to install from this repostitory directly, drop the `Data/Scripts/Library/deepcore` directory into your mod's `Data/Scripts/Library` folder. Override the default `GameScoring.lua` in `Data/Scripts/Miscellaneous` and `PGBase.lua` in `Data/Scripts/Library` with the ones provided in this repository.
