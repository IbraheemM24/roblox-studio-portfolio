# 🛡️ Roblox Anti-Cheat System

## Overview

The **Anti-Cheat System** is a security system developed in Roblox Studio to detect suspicious player behaviour, identify potential exploits, and enforce game security rules.

The system monitors player movement, character physics objects, and critical scripts to identify possible attempts to manipulate gameplay. It also includes a persistent ban system using Roblox DataStore, allowing banned players to be identified and removed when they attempt to rejoin the game.

A UserId-based whitelist allows specified players to be exempt from selected anti-cheat checks, while a manual ban table enables administrators to define bans directly within the script.

The system also provides an appeal message when a player is kicked, directing them to the specified Twitter account for further assistance.

## Features

- **Anti-Teleport Detection** – Monitors player movement and flags suspicious movement of 140 studs or more within one second.
- **Physics Exploit Detection** – Checks characters for potentially exploitable physics objects, including `BodyVelocity`, `BodyGyro`, `VectorForce`, `AlignPosition`, and `AlignOrientation`.
- **Humanoid Removal Detection** – Detects when a character's `Humanoid` is removed and kicks the player.
- **Anti-Cheat Script Protection** – Attempts to re-enable the `Anti` script if it becomes disabled and detects if the script is removed.
- **Main Script Protection** – Attempts to detect the removal or disabling of the `Main` script.
- **Persistent Ban System** – Stores banned players in a Roblox DataStore named `Bans`, allowing ban records to persist between sessions.
- **Join-Time Ban Checking** – Checks stored ban records when players join and kicks players who are banned.
- **UserId Whitelist** – Allows specified Roblox UserIds to be exempt from selected anti-cheat checks.
- **Manual Ban Table** – Includes a `manualban` table for specifying UserIds that should be manually banned.
- **Appeal System** – Displays a kick message directing removed players to contact the designated Twitter account to appeal their ban or removal.

##  Development

### Engine
- **Game Engine:** Roblox Studio
- **Platform:** Roblox

### Language
- **Primary Language:** Luau (Roblox's scripting language)

### Development Components

- **Player Monitoring:** Tracks character movement and monitors character components for suspicious changes.
- **Physics Validation:** Checks for selected physics-related instances within player characters.
- **Script Monitoring:** Monitors critical scripts for unexpected removal or disabling.
- **Data Persistence:** Uses Roblox DataStoreService to save and retrieve ban records.
- **Player Identification:** Uses Roblox UserIds for whitelist and manual ban management.
- **Join Validation:** Checks persistent ban records when players join and kicks banned players.
- **Enforcement and Appeals:** Uses player kicks with a custom message to communicate enforcement actions and provide appeal instructions.

