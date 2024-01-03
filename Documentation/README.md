# Documentation

## APFS Pathing

Default Absolute Paths 

- Mod Contents Directory: `"/Users/{USER}/Documents/Larian Studios/Baldur's Gate 3/Mods"`
- Mod Load Config File: `"/Users/{USER}/Documents/Larian Studios/Baldur's Gate 3/PlayerProfiles/Public/modsettings.lsx"`

Caution: The absolute path for the mod contents may depend on if the user is using [iCloud Drive optimizations](https://support.apple.com/en-us/HT206985)
-  Xcode should be able to resolve this path automatically
-  If the user is using iCloud Drive, then it *should* automatically download the contents of this folder upon request
-  However, given the potential size of this folder, as well as iCloud Drive inconsistencies, we may need to implement additional handling methods to ensure that all files are available offline

## Manual Modding Walkthrough

For this walkthrough, we are going to be installing and applying the [Faces of Faerun](https://www.nexusmods.com/baldursgate3/mods/429?tab=description) mod. Once we understand how to mod manually, we can begin to implement the most efficient method of programmatic implementation, as well beginning to consider proper UI/UX implementation. UX focus will be on mimicking existing mod implementation behavior (maintaining what existing modders have come to know), along with ease of use for prospective users who have perhaps shied away from modding in the past due to the preconceived complexity involved with modifying data structure files. I may also reference this [Reddit post](https://www.reddit.com/r/BaldursGate3/comments/15cksse/manual_modding_in_bg3_specifically_for_macos_users/) from a very helpful user.

1. Upon first downloading [Faces of Faerun](https://www.nexusmods.com/baldursgate3/mods/429), you will be alerted to some mod requirements:
    - [Baldur's Gate 3 Mod Fixer](https://www.nexusmods.com/baldursgate3/mods/141)
    - [ImprovedUI ReleaseReady](https://www.nexusmods.com/baldursgate3/mods/366)
  
   Neither mod requires modification of modsettings.lsx, thus no further action is required here. I will, however, make note of this as we still need to determine the optimal method of listing existing mod files that do require a specific load ordering in modsettings.lsx, as well as mod files that have yet to be added.

---

Before we proceed any further, let's take a look at the [default modsettings.lsx file](https://github.com/revblaze/BaldursModManager/Documentation/DefaultResourceFiles/default_modsettings.lsx):

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

According to the Reddit post, `GustavDev` is a default mod that always needs to be at the top of the mod load order (`priority: 1`). As such, we'll make a rule to never touch it (as well as any other code deemed necessary for the mod queue). We don't need to know more than that for now.

There are two components to the mod order queue: `ModOrder` and `Mods`. Note that the default state of this file has ModOrder in a self-closure, `<node id="ModOrder"/>`, which we'll need to open once we add to this list → `<node id="ModOrder">{CONTENTS}</node>`

#### `<node id="ModOrder">`
- This is order in which we'll be queuing the mods
- The list is comprised of UUID entries to reference each particular mod
- Each entry is embedded within child nodes with id `Module`

#### `<node id="Mods">`
- This list is comprised of mod metadata
- Metadata can generally be extracted from the info.json file included with each mod package
- Each entry is embedded within child nodes with id `ModuleShortDesc`

---

2. Now let's take a look at the [Faces of Faerun](https://www.nexusmods.com/baldursgate3/mods/429) manual installation steps provided (assuming we have already installed its two required mods listed above):

```xml
<node id="Module">
  <attribute id="UUID" value="8c611d4b-75d9-40eb-ad61-15f898396e12" type="FixedString" />
</node>

﻿﻿﻿﻿<node id="ModuleShortDesc">
  <attribute id="Folder" value="FoF" type="LSString" />
  <attribute id="MD5" value="" type="LSString" />
  <attribute id="Name" value="Faces of Faerûn" type="LSString" />
  <attribute id="UUID" value="8c611d4b-75d9-40eb-ad61-15f898396e12" type="FixedString" />
  <attribute id="Version64" value="36029297386049870" type="int64" />
</node>
```

---

These instructions are, of course, useful when it comes to manual installation. However, these may not always be available to us and so we'll probably want to install this mod based on the associated JSON file that comes packaged with it. Luckily, the above instructions provide an ideal look into how we might parse a JSON file that comes included with any given mod. Let's compare this to the info.json file that comes packaged with [Faces of Faerun](https://www.nexusmods.com/baldursgate3/mods/429):

```
{"Mods":[{"Author":"Aloija","Name":"Faces of Faerûn","Folder":"FoF","Version":null,"Description":"Custom head presets","UUID":"8c611d4b-75d9-40eb-ad61-15f898396e12","Created":"2024-01-02T23:07:37.7333033+03:00","Dependencies":[],"Group":"f3d1d2e0-02ad-4358-9eb4-a2b15b268892"}],"MD5":"53a5171895721837592334d05be1132c"}
```

For learning purposes, let's reformat this file to the JSON working standard such that it's more readable:

```json
{
  "Mods": [
    {
      "Author": "Aloija",
      "Name": "Faces of Faerûn",
      "Folder": "FoF",
      "Version": null,
      "Description": "Custom head presets",
      "UUID": "8c611d4b-75d9-40eb-ad61-15f898396e12",
      "Created": "2024-01-02T23:07:37.7333033+03:00",
      "Dependencies": [],
      "Group": "f3d1d2e0-02ad-4358-9eb4-a2b15b268892"
    }
  ],
  "MD5": "53a5171895721837592334d05be1132c"
}
```

The important parts we'll need to parse come with keys: `[Name, Folder, Version, UUID, MD5]`. We'll probably want to parse and extract all key-values of the JSON file for the UI; but, for now, these are the essential keys we require to get the mod working.

*Albeit, not all mods come pre-packaged with an info.json file. Perhaps we can implement a non-standard method of implementation for these mods if required. They may not even need custom adjustments, as seen with the requirements for Faces of Faerun.*

---

3. Next, we'll need to parse the JSON file such that we can translate its contents into the XML format structure. We already have XML entries via the manual installation steps above, so let's see how it fits altogether:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<save>
    <version major="4" minor="4" revision="0" build="300"/>
    <region id="ModuleSettings">
        <node id="root">
            <children>
                <node id="ModOrder">
                    <children>
                        <node id="Module">
                            <attribute id="UUID" value="991c9c7a-fb80-40cb-8f0d-b92d4e80e9b1" type="FixedString" />
                        </node>
                        <node id="Module">
                            <attribute id="UUID" value="8c611d4b-75d9-40eb-ad61-15f898396e12" type="FixedString" />
                        </node>
                    </children>
                </node>
                <node id="Mods">
                    <children>
                        <node id="ModuleShortDesc">
                            <attribute id="Folder" type="LSString" value="GustavDev"/>
                            <attribute id="MD5" type="LSString" value=""/>
                            <attribute id="Name" type="LSString" value="GustavDev"/>
                            <attribute id="UUID" type="FixedString" value="28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"/>
                            <attribute id="Version64" type="int64" value="36028797018963968"/>
                        </node>
                        <node id="ModuleShortDesc">
                            <attribute id="Folder" value="FoF" type="LSString" />
                            <attribute id="MD5" value="" type="LSString" />
                            <attribute id="Name" value="Faces of Faerûn" type="LSString" />
                            <attribute id="UUID" value="8c611d4b-75d9-40eb-ad61-15f898396e12" type="FixedString" />
                            <attribute id="Version64" value="36029297386049870" type="int64" />
                        </node>
                    </children>
                </node>
            </children>
        </node>
    </region>
</save>
```

4.  Save and done.

---

### Manual Modding Notes

- Always keep a backup of the original modsettings.lsx

#### Locked File Requirements(?)
u/Dapper-Ad3707 notes that the modsettings.lsx file needs to be unlocked for editing, and locked again after editing, to ensure that the game doesn't overwrite previous changes. I'll need to double check if this is still an issue, as the file was unlocked by default for version `4.1.1.4251417`.
- If this is an issue, manually applying `chmod` permissions should help to resolve it
- It'll likely be easiest for us to generate a new version of modsettings.lsx each time the load order is changed
  - Thus, simply creating a new file with custom permissions should resolve this

#### JSON parsing
u/Dapper-Ad3707 notes that some mods may use a `float` type, instead of an `int` type, for denoting the value of key `Version64`. We'll use their example to help portray this issue:

```
{"Mods":[{"Author":"clintmich","Name":"RaritiesOfTheRealms","Folder":"RaritiesOfTheRealms","Version":"1.0","Description":"Adds rare and unique items found in the DnD 5e rule set.","UUID":"d23881c2-f6b5-4e64-a2fe-f55c9538ab1e","Created":"2023-01-13T00:35:44.7257018-07:00","Dependencies":[],"Group":"e4b043fa-c72a-46e9-8d5d-7664cbac08d3"}],"MD5":"e8d7cc3971ea9a53f9e31843ada6b72a"}
```

The issue pertains to the entry: `"Version":"1.0"`. They suggest translating that to the XML file as such:

```xml
<attribute id="Version" type="float32" value="1.0" />
```

This appears to use a different `attribute id` vlaue to the previous entries, which used `"Version64"`. Perhaps this is due to the float value being specified as 32-bit. They acknowledge that they haven't yet tested this with float64 values. Perhaps we can play around with these upon testing.
