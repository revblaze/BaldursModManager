//
//  ContentView+LogSession.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/27/24.
//

import AppKit
import UniformTypeIdentifiers

extension ContentView {
  /// Exports the current session log to a file. This function initiates the process of creating a session log by gathering various pieces of application data and settings, logging them, and then saving the log to a file.
  func exportSessionLog() {
    global.exportSessionLog = false
    var appSupportDirPathString: String?
    
    Debug.logSection()
    Debug.log("----------------------")
    Debug.log("[Creating Log Session]")
    Debug.log("----------------------")
    Debug.logSection()
    
    // Log user settings
    Debug.log("[UserSettings]")
    Debug.log(UserSettings.shared.logUserSettings())
    
    // Log application support directory path
    if let appSupportDirPath = FileUtility.appSupportDirUrl()?.appendingPathComponent(Constants.ApplicationSupportFolderName).path(percentEncoded: false) {
      Debug.log("AppSupportDirUrl: \(appSupportDirPath)")
      Debug.log("> exists: \(appSupportDirPath.doesExist())")
      appSupportDirPathString = appSupportDirPath
    } else {
      Debug.log("AppSupportDirUrl: [ERROR]")
    }
    
    Debug.logSection()
    Debug.log("[Application Support Directory Contents]")
    Debug.log("----------------------------------------")
    if let appSupportDir = appSupportDirPathString, appSupportDir.doesExist() {
      Debug.log(appSupportDir.logDirectoryContents())
    } else {
      Debug.log("ERROR:\n  appSupportDirPathString = \(String(describing: appSupportDirPathString))\n  appSupportDirPathString.doesExist() = \(String(describing: appSupportDirPathString?.doesExist()))")
    }
    Debug.log("----------------------------------------")
    
    Debug.logSection()
    Debug.log("[Baldur's Gate 3 Documents Directory Contents]")
    Debug.log("----------------------------------------------")
    let gameDocumentsDir = UserSettings.shared.baldursGateDirectory
    if gameDocumentsDir.doesExist() {
      Debug.log(gameDocumentsDir.logDirectoryContents())
    } else {
      Debug.log("ERROR:\n  gameDocumentsDir = \(gameDocumentsDir)\n  gameDocumentsDir.doesExist() = \(gameDocumentsDir.doesExist())")
    }
    Debug.log("----------------------------------------------")
    
    // Log all ModItems
    Debug.logSection()
    Debug.log("[Log All ModItems]")
    ModItemUtility.logModItems(fetchAllModItemsSortedByOrder())
    Debug.logSection()
    
    // Log modsettings.lsx contents
    Debug.log("[modsettings.lsx]")
    if let modSettingsXml = generateModSettingsXmlContents() {
      Debug.log(modSettingsXml)
    } else {
      Debug.log("Error: Unable to log modsettings.lsx contents")
    }
    
    // Clean user paths from the session log and save the log file
    let cleanedSessionLog = Debug.shared.sessionLog.cleanUserPaths()
    saveLogFile(contents: cleanedSessionLog)
  }
  
  /// Saves the provided log contents to a file. This function presents a save panel to the user, allowing them to choose the location and name for the log file. If the user confirms the save, the contents are written to the selected file.
  ///
  /// - Parameter contents: The log contents to be saved to the file.
  func saveLogFile(contents: String) {
    let savePanel = NSSavePanel()
    savePanel.title = "Save Log File"
    savePanel.allowedContentTypes = [UTType.plainText]
    savePanel.nameFieldStringValue = "BMM Session".appendingDateAndTime().appending(".log")
    
    savePanel.begin { result in
      if result == .OK, let url = savePanel.url {
        do {
          try contents.write(to: url, atomically: true, encoding: .utf8)
          Debug.log("Log file saved to \(url.path)")
        } catch {
          Debug.log("Error saving log file: \(error.localizedDescription)")
        }
      } else {
        Debug.log("Save panel was cancelled")
      }
    }
  }
}
