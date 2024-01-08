# BaldursModManager
Baldur's Gate 3 Mod Manager for macOS

<sup>This mod manager is currently in active development and does not function as expected. I will update the [Releases](https://github.com/revblaze/BaldursModManager/releases) page once there is something to test!</sup>

<img width="843" alt="Screenshot 2024-01-05 at 3 52 30 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/d7af718f-4468-4894-9638-53864b1e00b6">

<i>For pre-development planning, see the [Documentation](/Documentation/) section.</i>

## Table of Contents

1. [TODO](#todo)
2. [How It Works](#how-it-works)
3. [File Management](#file-management)
4. [APFS Permissions](#apfs-permissions)
5. [Mod Types](#mod-types)
6. [System Requirements](#system-requirements)
7. [Resources](#resources)
8. [Credits](#credits)

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
  - [x] Copy/move mod folder to Application Support/Documents on import
  - [x] Handling of `.pak` file location based on `isEnabled` status
  - [x] Remove mod folder contents on Delete
- [ ] `modsettings.lsx`
  - [ ] modsettings XML version/build check on launch
    - [ ] Backup default modsettings file for restore (remove all mods) functionality
    - [ ] Use latest XML version/build tags for generation
  - [ ] Mod load order XML generation based on `isEnabled` status
  - [ ] Save Load Order button action → backup lsx (rename), generate new lsx

## How It Works

Upon downloading a mod package, you'll be given a mod folder with two files: `info.json` and some `.pak` file. Simply drag and drop that mod folder into the app to get started...

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

If the `info.json` file can be parsed (it contains the required fields `Name, Folder, UUID, MD5`) then the mod folder will be accepted. 

From here, the mod folder will be stored in the app's `Application Support/` directory. Simultaneously, a new entry will be added to the app's local database that will include a reference to the mod folder directory, as well as the metadata parsed from the JSON file. Each new entry will also be added to the end of the load order list and given an order number based on its position in the list. 

### Load Order

Rearranging mods in the sidebar will update the order number of each mod, respective to their new position in the list.

### Enabling / Disabling

Newly added mods are disabled by default. 

<b><i>Enabling</i></b> a mod will move that mod's `.pak` file to the BG3 `Mods/` directory. It will also queue the metadata (parsed from the JSON file) to be added to the `modsettings.lsx` file. 

<b><i>Disabling</i></b> a mod will move the `.pak` file back to the mod folder (in the app's `Application Support/` directory), and will remove its associated metadata from the `modsettings.lsx` queue.

### Saving / Restoring

<b><i>Save Mod Settings</i></b> will backup the existing `modsettings.lsx` file and replace it with a new, identical file that includes the metadata of the enabled mods in your load order. The order in which these mods are added will depend on their order in the list. This new modsettings file will be given permissions that mimic the system's file-locking functionality, as seen in the Finder app.

Adding new mods, enabling/disabling existings mods and/or modifying the load order–followed by <b><i>Save Mod Settings</i></b>–will simply replace the existing `modsettings.lsx` file with a newly generated one.

<b><i>Restore Mod Settings</i></b> will replace any existing `modsettings.lsx` file with the one that was initially backed up from the first time you saved mod settings.

</details>

## File Management

Mod path management, async file transfers, version control, etc.

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

### Application Support Overview

```
BaldursModManager/
    default.store
    UserBackups/
        modsettings.lsx {timestamp}
    UserMods/
        mod-folder/
            info.json
            mod-file.pak
```

### `modsettings.lsx` backups

Stored in the Application Support `UserBackups/` directory.

<img width="1042" alt="Screenshot 2024-01-08 at 7 40 03 AM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/56e5936b-ba62-4180-b02a-1919978c3215">

</details>

## APFS Permissions

As of macOS 14, file management is still possible outside of the App Sandbox. However, [PermissionsView.swift](https://github.com/revblaze/BaldursModManager/blob/main/BaldursModManager/Views/PermissionsView.swift) has been implemented for the case that individual file and folder permissions are required in the future.

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

<img width="1012" alt="Screenshot 2024-01-07 at 3 53 09 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/b1dc8690-300d-44e2-92a1-0fec3e1cfc95">
<img width="1012" alt="Screenshot 2024-01-07 at 3 53 18 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/234a4478-b89b-42cc-b5b5-60c85b1c3826">
<img width="1012" alt="Screenshot 2024-01-07 at 3 53 36 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/17e4dd96-1d17-4c2f-9fa1-38d7e6331437">

</details>

## Mod Types

<i>Initially, this mod manager will feature support for downloadable mod folders that contain a `.pak` file and an `info.json` file (`.pakFileWithJson`). This section is mostly for potential future plans.</i>

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

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
