<p align="center"><img width="150px" height="150px" src="https://github.com/revblaze/BaldursModManager/blob/main/BaldursModManager/Assets.xcassets/AppIcon.appiconset/icon_1024.png?raw=true" /></p>

# BaldursModManager
Baldur's Gate 3 Mod Manager for macOS

<sup>This mod manager is currently in active development and may not function as expected. Please submit [issues](https://github.com/revblaze/BaldursModManager/issues) for the most recent build available.</sup>

To download the latest version, check [Releases](https://github.com/revblaze/BaldursModManager/releases).

<img width="913" alt="Screenshot 2024-01-08 at 9 18 16 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/2504bdb3-a766-435b-a70d-40f9f97d981a">

<details>

<summary><h4>Expand to See Screenshots</h4></summary>

<img width="913" alt="Screenshot 2024-01-08 at 9 18 33 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/463dec79-6fc8-4fee-998b-a19b15faecf2">
<img width="972" alt="Screenshot 2024-01-08 at 9 19 16 PM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/129b03c3-4531-4179-8cb1-e81aaeef9050">

</details>

<i>For pre-development planning, see the [Documentation](/Documentation/) section.</i>

## Table of Contents

1. [How It Works](#how-it-works)
2. [File Management](#file-management)
3. [XML-LSX Parsing](#xml-lsx-parsing)
4. [APFS Permissions](#apfs-permissions)
5. [Mod Types](#mod-types)
6. [System Requirements](#system-requirements)
7. [Resources](#resources)
8. [Acknowledgements](#acknowledgements)

<details>

<summary><h4>TODO (Archived)</h4></summary>

- [x] SwiftData implementation
- [x] JSON mod metadata parsing (`info.json`)
- [x] NavigationView (master)
  - [x] Add ModItem to SwiftData store
  - [x] Delete ModItem from SwiftData store 
  - [x] Drag/drop ModItem to set load order
- [x] ModItemDetailView (detail)
  - [x] Populate with metadata from parsed JSON
  - [x] Toggle modItem's `isEnabled` state
- [x] File management
  - [x] UserSettings: Option for copy or move on mod import 
  - [x] Copy/move mod folder to Application Support/Documents on import
  - [x] Handling of `.pak` file location based on `isEnabled` status
  - [x] Remove mod folder contents on Delete
- [x] `modsettings.lsx`
  - [ ] modsettings XML version/build check on launch
    - [ ] Backup default modsettings file for restore (remove all mods) functionality
    - [x] Use latest XML version/build tags for generation
  - [x] Mod load order XML generation based on `isEnabled` status
  - [x] Save Load Order button action → backup lsx (rename), generate new lsx
     
 </details>

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

### Application Support Structure

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

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

### `modsettings.lsx` Backup Management

Stored in the Application Support `UserBackups/` directory.

<img width="1042" alt="Screenshot 2024-01-08 at 7 40 03 AM" src="https://github.com/revblaze/BaldursModManager/assets/1476332/56e5936b-ba62-4180-b02a-1919978c3215">

</details>

## XML-LSX Parsing

Alongside creating a backup of each modsettings.lsx file, we also need to parse its contents for attribute values. We not only need to do this on first backup, but every backup henceforth due to the possibility that BG3 may update these values with future patches. Finally, we also need to replicate the GustavDev embedded attributes within the ModuleShortDesc as its values may change as well–this goes especially for associated values to attribute IDs UUID and Version64.

<details>

<summary><h4>Expand to Continue Reading</h4></summary>

This current version of the parser is extremely hacky and specifically designed to work with the `modsettings.lsx` file structure. I welcome any help on this front, as I'm no XML parsing expert. For the meantime, this solution should at least work for our purposes.

Input sample (default) `modsettings.lsx` from BG3 version 4.1.1.4251417:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<save>
    <version major="4" minor="4" revision="0" build="300"/>
    <region id="ModuleSettings">
        <node id="root">
            <children>
                <node id="ModOrder"/>
                <node id="Mods">
                    <children>
                        <node id="ModuleShortDesc">
                            <attribute id="Folder" type="LSString" value="GustavDev"/>
                            <attribute id="MD5" type="LSString" value=""/>
                            <attribute id="Name" type="LSString" value="GustavDev"/>
                            <attribute id="UUID" type="FixedString" value="28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"/>
                            <attribute id="Version64" type="int64" value="36028797018963968"/>
                        </node>
                    </children>
                </node>
            </children>
        </node>
    </region>
</save>
```

We'll need to create our own XMLAttributes structure to store these values:

```swift
struct XMLAttributes {
  var version: Version
  var moduleShortDesc: ModuleShortDesc
  
  struct Version {
    var majorString: String
    var minorString: String
    var revisionString: String
    var buildString: String
  }
  
  struct ModuleShortDesc {
    var folder: Attribute
    var md5: Attribute
    var name: Attribute
    var uuid: Attribute
    var version64: Attribute
    
    struct Attribute {
      var typeString: String
      var valueString: String
    }
  }
}
```

Our LsxParserDelegate class will then extract this data, storing them as (kinda) "type-safe(ish)" variables. From there, we can call them as such to help re-generate the modsettings.lsx file anew:

### XML `version` Header

```swift
let majorVersion = xmlAttrs.version.majorString
let minorVersion = xmlAttrs.version.minorString
let revisionVersion = xmlAttrs.version.revisionString
let buildVersion = xmlAttrs.version.buildString

let versionXmlString = 
"""
<version major="\(majorVersion)" minor="\(minorVersion)" revision="\(revisionVersion)" build="\(buildVersion)"/>
"""

print(versionXmlString)
```

Output:

```xml
<version major="4" minor="4" revision="0" build="300"/>
```

### XML `ModuleShortDesc` Child Nodes

```swift
let gustavDevGeneratedAttributes = 
"""
<attribute id="Folder" type="\(gustavDevModule.folder.typeString)" value="\(gustavDevModule.folder.valueString)"/>
<attribute id="MD5" type="\(gustavDevModule.md5.typeString)" value="\(gustavDevModule.md5.valueString)"/>
<attribute id="Name" type="\(gustavDevModule.name.typeString)" value="\(gustavDevModule.name.valueString)"/>
<attribute id="UUID" type="\(gustavDevModule.uuid.typeString)" value="\(gustavDevModule.uuid.valueString)"/>
<attribute id="Version64" type="\(gustavDevModule.version64.typeString)" value="\(gustavDevModule.version64.valueString)"/>
"""

print(gustavDevGeneratedAttributes)
```

Output:

```xml
<attribute id="Folder" type="LSString" value="GustavDev"/>
<attribute id="MD5" type="LSString" value=""/>
<attribute id="Name" type="LSString" value="GustavDev"/>
<attribute id="UUID" type="FixedString" value="28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"/>
<attribute id="Version64" type="int64" value="36028797018963968"/>
```

Refer to the specific [pull request](https://github.com/revblaze/BaldursModManager/pull/19) for more details on this implementation.

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

## Acknowledgements

- `u/TheMetaHorde` for walking me through mod fundamentals, providing niche cases and being very friendly :)
- `u/Dapper-Ad3707` for some very helpful technical writeups on manual modding methodology
