# BaldursModManager
Baldur's Gate 3 Mod Manager for macOS

<sup>This mod manager is currently in active development and does not function as expected. I will update the [Releases](https://github.com/revblaze/BaldursModManager/releases) page once there is something to test!</sup>

<img width="843" alt="Screenshot 2024-01-05 at 3 52 30 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/d7af718f-4468-4894-9638-53864b1e00b6">

<i>For pre-development planning, see the [Documentation](/Documentation/) section.</i>

## Table of Contents

1. [TODO](#todo)
2. [Mod Types](#mod-types)
3. [System Requirements](#system-requirements)
4. [Resources](#resources)
5. [Credits](#credits)

## TODO

- [x] SwiftData implementation
- [x] JSON mod metadata parsing (`info.json`)
- [x] NavigationView (master)
  - [x] Add ModItem to SwiftData store
  - [x] Delete ModItem from SwiftData store 
  - [x] Drag/drop ModItem to set load order
- [x] ModItemDetailView (detail)
  - [x] Populate with metadata from parsed JSON
  - [x] Toggle modItem's `isEnabled` state
- [ ] File management
  - [ ] UserSettings: Option for copy or move on mod import 
  - [ ] Copy/move mod folder to Application Support/Documents on import
  - [ ] Handling of `.pak` file location based on `isEnabled` status
  - [ ] Remove mod folder contents on Delete
- [ ] `modsettings.lsx`
  - [ ] modsettings XML version/build check on launch
    - [ ] Backup default modsettings file for restore (remove all mods) functionality
    - [ ] Use latest XML version/build tags for generation
  - [ ] Mod load order XML generation based on `isEnabled` status
  - [ ] Save Load Order button action → backup lsx (rename), generate new lsx

## Mod Types

<i>Initially, this mod manager will feature support for downloadable mod folders that contain a `.pak` file and an `info.json` file (`.pakFileWithJson`). This section is mostly for potential future plans.</i>

<details>

<summary><h4>Expand Section</h4></summary>

```swift
enum ModType {
  case pakFile
  case pakFileWithUuid
  case pakFileWithJson
  case replaceFileStructure
}
```

`.pakFile` <i>ie. [Baldur's Gate 3 Mod Fixer](https://www.nexusmods.com/baldursgate3/mods/141)</i>
  - Mod contents: PAK file
  - PAK file simply needs to be placed in `Mods/` folder for it to work

`.pakFileWithUuid` <i>ie. [UnlockLevelCurve](https://www.nexusmods.com/baldursgate3/mods/377)</i>
  - Mod contents: PAK file
  - Mod description contains UUID values per associated PAK file
  - PAK file needs to be placed in `Mods/` folder; UUID key-value must be added to modsettings.lsx

`.pakFileWithJson` <i>ie. [Faces of Faerun](https://www.nexusmods.com/baldursgate3/mods/429)</i>
  - Mod contents: PAK file, info.json
  - PAK file needs to be placed in `Mods/` folder; JSON contents must be parsed and added to modsettings.lsx

`.replaceFileStructure` <i>ie. [Level 20 (Multiclass)](https://www.nexusmods.com/baldursgate3/mods/570)</i>
  - Mod contents: file-folder structure that mimics game data files (`{MOD}/Data/Public/.../file`)
  - Files need to replace existing files at their exact locations
  - `{MOD}/Data/Public/.../file` → `{GAME}/Data/Public/.../file`

</details>

## System Requirements

Requires macOS 14+ (Sonoma and later).

<sup>This requirement is mostly due to the [SwiftData](https://developer.apple.com/documentation/swiftdata) implementation. This was to ensure that the underlying code will be compatible with macOS for as long as possible. Due to the open source nature of this project, anyone is more than welcome to implement backwards compatibility with the [Core Data](https://developer.apple.com/documentation/coredata) framework.

## Resources

- [Fix Stuck Loading Main Menu - Fake GustavDev](https://www.nexusmods.com/baldursgate3/mods/611) (Nexus)
- [Manual Modding in BG3, specifically for MacOS users by u/Dapper-Ad3707](https://www.reddit.com/r/BaldursGate3/comments/15cksse/manual_modding_in_bg3_specifically_for_macos_users/) (Reddit)

## Credits

```
u/TheMetaHorde
u/Dapper-Ad3707
```
