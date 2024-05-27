//
//  ContentView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import SwiftUI
import SwiftData
import AlertToast

let UIDELAY: CGFloat = 0.01

struct ContentView: View {
  @Environment(\.global) var global
  @Environment(\.updateManager) var updateManager
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \ModItem.order, order: .forward) private var modItems: [ModItem]
  @State private var selectedModItem: ModItem?
  @State private var showAlertForModDeletion = false
  @State private var showPermissionsView = false
  
  @State private var offsetsToDelete: IndexSet?
  @State private var modItemToDelete: ModItem?
  @State private var isFileTransferInProgress = false
  @State private var fileTransferProgress: Double = 0
  
  @State private var showXmlPreview = false
  @State private var previewXmlContent = ""
  
  @State private var showCheckmarkForRestore = false
  @State private var showCheckmarkForSync = false
  @State private var showConfirmationText = false
  @State private var confirmationMessage = ""
  
  @State private var showToastSuccess = false
  @State private var toastSuccessMessage = ""
  @State private var showToastError = false
  @State private var toastErrorMessage = ""
  @State private var showReportProblemButton = false
  
  func showToastSuccess(_ message: String) {
    Debug.log("[Toast] \(message)")
    toastSuccessMessage = message
    showToastSuccess = true
  }
  
  func showToastError(_ message: String, withLogDetails logDetails: String = "") {
    Debug.log("[Toast] Error: \(message)")
    if !logDetails.isEmpty {
      Debug.log("Log Details: \(logDetails)")
    }
    toastErrorMessage = message
    showToastError = true
    
    showReportProblemButton = true
  }
  
  private let modItemManager = ModItemManager.shared
  var debug = Debug.shared
  
  private func fetchEnabledModItemsSortedByOrder() -> [ModItem] {
    let predicate = #Predicate { (modItem: ModItem) in
      modItem.isEnabled == true
    }
    let sortDescriptor = SortDescriptor(\ModItem.order)
    let fetchDescriptor = FetchDescriptor<ModItem>(predicate: predicate, sortBy: [sortDescriptor])
    
    do {
      let modItems = try modelContext.fetch(fetchDescriptor)
      return modItems
    } catch {
      Debug.log("Failed to load ModItem model: \(error)")
      return []
    }
  }
  
  func fetchAllModItemsSortedByOrder() -> [ModItem] {
    let sortDescriptor = SortDescriptor(\ModItem.order)
    let fetchDescriptor = FetchDescriptor<ModItem>(sortBy: [sortDescriptor])
    
    do {
      let modItems = try modelContext.fetch(fetchDescriptor)
      return modItems
    } catch {
      Debug.log("Failed to load ModItem models: \(error)")
      return []
    }
  }
  
  func save() {
    Debug.log("Saving...")
    do {
      try modelContext.save()
    } catch {
      showToastError("Failed to save to local database.", withLogDetails: error.localizedDescription)
    }
    
    if !UserSettings.shared.enableMods {
      restoreDefaultModSettingsLsx(withToast: false)
    } else if UserSettings.shared.saveModsAutomatically {
      generateAndSaveModSettingsLsx(withToast: false)
    }
  }
  
  private func performInitialSetup() {
    FileUtility.createUserModsAndBackupFoldersIfNeeded()
    FileUtility.removeBackupModSettingsDirectory()
    checkForUpdatesIfAutomaticUpdatesAreEnabled()
  }
  
  private func selectModItem(_ item: ModItem?) {
    selectedModItem = item
    if let item = item {
      Debug.log("Selected mod item with order: \(item.order), name: \(item.modName)")
    }
  }
  
  var body: some View {
    @Bindable var global = global
    NavigationSplitView {
      List(selection: $selectedModItem) {
        ForEach(modItems) { item in
          NavigationLink {
            ModItemDetailView(item: item, deleteAction: deleteItem, saveAction: save)
          } label: {
            HStack {
              SidebarItemView(item: item)
            }
          }
          .tag(item)
        }
        .onDelete(perform: deleteItems)
        .onMove(perform: moveItems)
      }
      .onChange(of: selectedModItem) {
        selectModItem(selectedModItem)
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(min: 200, ideal: 260)
      // MARK: Navigation Toolbar
      .toolbar {
        ToolbarItem {
          ToolbarSymbolButton(title: "Import Mod", symbol: .plus, action: addItem)
            .onChange(of: global.showImportModPanel) {
              if global.showImportModPanel { addItem() }
            }
        }
        ToolbarItem(placement: .navigation) {
          ToolbarSymbolButton(title: "Home", symbol: .house, tint: selectedModItem == nil ? .blue : .secondary) {
            selectedModItem = nil
          }
        }
        ToolbarItem(placement: .principal) {
          Spacer()
        }
      }
    } detail: {
      if let selectedModItem {
        ModItemDetailView(item: selectedModItem, deleteAction: deleteItem, saveAction: save)
      } else {
        WelcomeDetailView()
      }
    }
    .navigationTitle("Baldur's Mod Manager")
    .toolbar {
      
      if showReportProblemButton {
        ToolbarItem {
          MenuButton(title: "Experiencing Issues?") {
            global.showExperiencingIssuesView = true
            showReportProblemButton = false
          }
        }
      }
      
      ToolbarItem {
        if Debug.fileTransferUI || isFileTransferInProgress {
          ProgressView(value: fileTransferProgress, total: 1.0)
            .frame(width: 100)
            .opacity(fileTransferProgress > 0 ? 1 : 0)
        }
      }
      
      if !UserSettings.shared.saveModsAutomatically {
        if showConfirmationText {
          ToolbarItem {
            Text(confirmationMessage)
              .opacity(showConfirmationText ? 1 : 0)
              .animation(.easeInOut(duration: 0.5), value: showConfirmationText)
          }
        }
        
        ToolbarItem {
          Button(action: {
            restoreDefaultModSettingsLsx()
            showCheckmarkForRestore = true
            confirmationMessage = "Restored"
            showConfirmationText = true
            resetButtonAndMessage()
          }) {
            Label("Restore", systemImage: showCheckmarkForRestore ? "checkmark" : "gobackward")
          }
        }
        
        ToolbarItem {
          Button(action: {
            generateAndSaveModSettingsLsx()
            showCheckmarkForSync = true
            confirmationMessage = "Saved"
            showConfirmationText = true
            resetButtonAndMessage()
          }) {
            Label("Sync", systemImage: showCheckmarkForSync ? "checkmark" : "arrow.triangle.2.circlepath")
          }
        }
        ToolbarItem {
          HStack {
            Divider()
          }
        }
      }
      
      ToolbarItem {
        Menu {
          MenuButton(title: "What's New", symbol: .sparkles) {
            global.showWhatsNewView = true
          }
          Divider()
          MenuButton(title: "Preview LSX", symbol: .curlyBraces, action: previewModSettingsLsx)
          if debug.isActive {
            MenuButton(title: "Open Mod Folder", symbol: .folder, action: openUserModsFolder)
          }
          Divider()
          MenuButton(title: "Nexus Page", symbol: .gyro) {
            Constants.NexusUrl.openAsURL()
          }
          MenuButton(title: "GitHub Page", symbol: .pull) {
            Constants.GitHubUrl.openAsURL()
          }
          Divider()
          MenuButton(title: "Report Issue", symbol: .newMessage) {
            Constants.ReportIssue.openAsURL()
          }
          MenuButton(title: "Export Session Log", symbol: .downloadDoc) {
            global.exportSessionLog = true
          }
          Divider()
          MenuButton(title: "Experiencing Issues?", symbol: .help) {
            global.showExperiencingIssuesView = true
          }
        } label: {
          Label("Actions", systemImage: "ellipsis.circle")
        }
      }
      
      ToolbarItem {
        ToolbarSymbolButton(title: "Settings", symbol: .gear) {
          global.showSettingsView = true
        }
      }
    }
    // MARK: Alerts
    .alert(isPresented: $showAlertForModDeletion) {
      Alert(
        title: Text("Remove Mod"),
        message: Text("Are you sure you want to remove this mod? It will be moved to the trash."),
        primaryButton: .destructive(Text("Move to Trash")) {
          deleteModItems(at: offsetsToDelete, itemToDelete: modItemToDelete)
        },
        secondaryButton: .cancel()
      )
    }
    // MARK: Toasts
    .toast(isPresenting: $showToastError, duration: 6) {
      AlertToast(displayMode: .banner(.pop), type: .error(.red), title: toastErrorMessage)
    }
    .toast(isPresenting: $showToastSuccess, duration: 4) {
      AlertToast(type: .complete(.green), title: toastSuccessMessage)
    }
    .sheet(isPresented: $showPermissionsView) {
      PermissionsView(onDismiss: {
        self.showPermissionsView = false
      })
    }
    .sheet(isPresented: $global.showSettingsView) {
      SettingsView(isPresented: $global.showSettingsView)
        .frame(minWidth: 400, idealWidth: 600, maxWidth: 600, minHeight: 400, idealHeight: 700, maxHeight: 700)
    }
    .sheet(isPresented: $global.showUpdateView) {
      UpdateView(isPresented: $global.showUpdateView)
        .frame(width: 400, height: 300)
    }
    .sheet(isPresented: $global.showWhatsNewView) {
      WhatsNewView(isPresented: $global.showWhatsNewView)
        .frame(width: 550, height: 470)
    }
    .sheet(isPresented: $global.showExperiencingIssuesView) {
      ExperiencingIssuesView(isPresented: $global.showExperiencingIssuesView)
        .frame(width: 600, height: 550)
    }
    .sheet(isPresented: $showXmlPreview) {
      XMLPreviewView(xmlContent: $previewXmlContent)
    }
    .onChange(of: global.exportSessionLog) {
      if global.exportSessionLog { exportSessionLog() }
    }
    .onChange(of: debug.logModItems) {
      if debug.logModItems { ModItemUtility.logModItems(modItems) }
    }
    .onChange(of: debug.simulateErrorToast) {
      showToastError("This is a simulated error toast")
    }
    .onAppear {
      performInitialSetup()
      if Debug.permissionsView {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.showPermissionsView = true
        }
      }
    }
  }
  
  private func resetButtonAndMessage() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      showCheckmarkForRestore = false
      showCheckmarkForSync = false
      withAnimation {
        showConfirmationText = false
      }
    }
  }
  
  func generateModSettingsXmlContents() -> String? {
    guard let xmlAttributes = LsxUtility.parseFileContents(FileUtility.getDefaultModSettingsLsxFile()) else {
      return nil
    }
    
    let modItems = fetchEnabledModItemsSortedByOrder()
    let xmlBuilder = XMLBuilder(xmlAttributes: xmlAttributes, modItems: modItems)
    let xmlString = xmlBuilder.buildXMLString()
    return xmlString
  }
  
  private func generateAndSaveModSettingsLsx(withToast toast: Bool = true) {
    guard let xmlContents = generateModSettingsXmlContents() else {
      showToastError("Unable to generate mod settings XML contents")
      return
    }
    FileUtility.replaceModSettingsLsxInUserDocuments(withFileContents: xmlContents)
    if !UserSettings.shared.saveModsAutomatically {
      showToastSuccess("Mod settings applied")
    }
  }
  
  private func restoreDefaultModSettingsLsx(withToast toast: Bool = true) {
    let contents = FileUtility.getDefaultModSettingsLsxContents()
    FileUtility.replaceModSettingsLsxInUserDocuments(withFileContents: contents)
    showToastSuccess("Mod settings restored to default")
  }
  
  private func previewModSettingsLsx() {
    if UserSettings.shared.enableMods, let xmlAttributes = LsxUtility.parseFileContents(FileUtility.getDefaultModSettingsLsxFile()) {
      let modItems = fetchEnabledModItemsSortedByOrder()
      let xmlBuilder = XMLBuilder(xmlAttributes: xmlAttributes, modItems: modItems)
      previewXmlContent = xmlBuilder.buildXMLString()
    } else {
      previewXmlContent = FileUtility.getDefaultModSettingsLsxContents()
    }
    showXmlPreview = true
  }
  
  private func openUserModsFolder() {
    if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let userModsURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName)
      NSWorkspace.shared.open(userModsURL)
    }
  }
  
  private func addItem() {
    selectFile()
  }
  
  private func moveItems(from source: IndexSet, to destination: Int) {
    var reorderedItems = modItems
    reorderedItems.move(fromOffsets: source, toOffset: destination)
    for (index, item) in reorderedItems.enumerated() {
      item.order = index
      Debug.log("Updated mod item order: \(item.modName) to \(index)")
    }
    save()
  }
  
  private func selectFile() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.begin { response in
      if response == .OK, let selectedDirectory = openPanel.url {
        Debug.log("Selected directory: \(selectedDirectory.path)")
        parseImportedModFolder(at: selectedDirectory)
      }
    }
  }
  
  private func parseImportedModFolder(at url: URL) {
    if let contents = getDirectoryContents(at: url) {
      if let infoJsonUrl = contents.first(where: { $0.caseInsensitiveCompare("info.json") == .orderedSame }) {
        let fullPath = url.appendingPathComponent(infoJsonUrl).path
        
        if let infoDict = parseJsonToDict(atPath: fullPath) {
          Debug.log("JSON contents: \n\(infoDict)")
          createNewModItemFrom(infoDict: infoDict, infoJsonPath: fullPath, directoryContents: contents)
        } else {
          showToastError("Error parsing JSON content.")
        }
      } else {
        showToastError("Unable to locate info.json file of imported mod.")
      }
    }
  }
  
  private func getModItem(byUuid uuid: String) -> ModItem? {
    return modItems.first(where: { $0.modUuid == uuid })
  }
  
  private func deleteModItem(byUuid uuid: String, forUpdateReplacement willReplaceUpdate: Bool = false) -> Bool {
    if let modItemToDelete = getModItem(byUuid: uuid) {
      withAnimation {
        if modItemToDelete.isEnabled {
          modItemManager.movePakFileToOriginalLocation(modItemToDelete)
        }
        modelContext.delete(modItemToDelete)
        FileUtility.moveModItemToTrash(modItemToDelete)
        save()
        if willReplaceUpdate == false {
          updateOrderOfModItems()
        }
      }
      return true
    } else {
      showToastError("No mod found with UUID: \(uuid)")
      return false
    }
  }
  
  private func createNewModItemFrom(infoDict: [String: String], infoJsonPath: String, directoryContents: [String]) {
    let directoryURL = URL(fileURLWithPath: infoJsonPath).deletingLastPathComponent()
    
    if let pakFileString = getPakFileString(fromDirectoryContents: directoryContents) {
      var name, folder, uuid, md5: String?
      for (key, value) in infoDict {
        switch key.lowercased() {
        case "name": name = value
        case "folder": folder = value
        case "uuid": uuid = value
        case "md5": md5 = value
        default: break
        }
      }
      
      if let name = name, let folder = folder, let uuid = uuid, let md5 = md5 {
        var newOrderNumber = nextOrderValue()
        var replaceWithOrderNumber: Int?
        
        // Check if the mod item needs replacing
        if let modItemNeedsReplacing = getModItem(byUuid: uuid) {
          replaceWithOrderNumber = modItemNeedsReplacing.order
          let success = deleteModItem(byUuid: uuid, forUpdateReplacement: true)
          if success {
            if let oldOrderNumber = replaceWithOrderNumber {
              newOrderNumber = oldOrderNumber
              showToastSuccess("Mod updated successfully")
            }
          } else {
            showToastError("Unable to delete mod \(modItemNeedsReplacing.modName)")
            return
          }
        }
        
        withAnimation {
          let newModItem = ModItem(
            order: newOrderNumber,
            directoryUrl: directoryURL,
            directoryPath: directoryURL.path,
            directoryContents: directoryContents,
            pakFileString: pakFileString,
            name: name,
            folder: folder,
            uuid: uuid,
            md5: md5
          )
          
          // Check for optional keys
          for (key, value) in infoDict {
            switch key.lowercased() {
            case "author": newModItem.modAuthor = value
            case "description": newModItem.modDescription = value
            case "created": newModItem.modCreatedDate = value
            case "group": newModItem.modGroup = value
            case "version": newModItem.modVersion = value
            default: break
            }
          }
          Debug.log("Adding new mod item with order: \(newOrderNumber), name: \(name)")
          addNewModItem(newModItem, orderNumber: newOrderNumber, fromDirectoryUrl: directoryURL) {
            
            if UserSettings.shared.enableModOnImport {
              withAnimation {
                newModItem.isEnabled.toggle()
                modItemManager.toggleModItem(newModItem)
                save()
                updateOrderOfModItems()
              }
            }
          }
        }
      }
    } else {
      Debug.log("Error: Unable to resolve pakFileString from \(directoryContents)")
      showToastError("Unable to resolve pakFileString", withLogDetails: "from directoryContents: \(directoryContents)")
    }
  }
  
  private func addNewModItem(_ modItem: ModItem, orderNumber: Int, fromDirectoryUrl directoryUrl: URL, completion: @escaping () -> Void) {
    modelContext.insert(modItem)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + UIDELAY) {
      selectModItem(modItem)
      Debug.log("Added new mod item with order: \(orderNumber), name: \(modItem.modName)")
      importModFolderAndUpdateModItemDirectoryPath(at: directoryUrl, modItem: modItem, progress: $fileTransferProgress) {
        completion()
      }
    }
  }
  
  private func getDirectoryContents(at url: URL) -> [String]? {
    do {
      let fileManager = FileManager.default
      let contents = try fileManager.contentsOfDirectory(atPath: url.path)
      Debug.log("Directory contents: \(contents)")
      return contents
    } catch {
      showToastError("Unable to list directory contents", withLogDetails: "\(error)")
    }
    return nil
  }
  
  private func getPakFileString(fromDirectoryContents directoryContents: [String]) -> String? {
    for file in directoryContents {
      if file.lowercased().hasSuffix(".pak") {
        return file
      }
    }
    return nil
  }
  
  func parseJsonToDict(atPath filePath: String) -> [String: String]? {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
      do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = jsonObject as? [String: Any],
           let mods = dict["Mods"] as? [[String: Any]],
           let firstMod = mods.first {
          var result: [String: String] = [:]
          // Extract key-value pairs from the "Mods" dictionary
          for (key, value) in firstMod {
            if let stringValue = value as? String {
              result[key] = stringValue
            }
          }
          // Extract MD5 from the top-level dictionary
          if let md5 = dict["MD5"] as? String {
            result["MD5"] = md5
          }
          return result
        }
      } catch {
        showToastError("Error parsing Info.json contents", withLogDetails: error.localizedDescription)
      }
    }
    return nil
  }
  
  private func deleteItem(item: ModItem) {
    modItemToDelete = item
    offsetsToDelete = nil
    showAlertForModDeletion = true
  }
  
  private func deleteItems(offsets: IndexSet) {
    offsetsToDelete = offsets
    modItemToDelete = nil
    showAlertForModDeletion = true
  }
  
  private func deleteModItems(at offsets: IndexSet? = nil, itemToDelete: ModItem? = nil) {
    var indexToSelect: Int?
    
    withAnimation {
      if let offsets = offsets {
        for index in offsets.sorted().reversed() {
          if index < modItems.count {
            let modItem = modItems[index]
            if modItem.isEnabled {
              modItemManager.movePakFileToOriginalLocation(modItem)
            }
            indexToSelect = index
            modelContext.delete(modItem)
            FileUtility.moveModItemToTrash(modItem)
            Debug.log("Deleted mod item with order: \(modItem.order), name: \(modItem.modName)")
          }
        }
      } else if let modItem = itemToDelete {
        if modItem.isEnabled {
          modItemManager.movePakFileToOriginalLocation(modItem)
        }
        if let index = modItems.firstIndex(of: modItem) {
          indexToSelect = index
          modelContext.delete(modItem)
          FileUtility.moveModItemToTrash(modItem)
          Debug.log("Deleted mod item with order: \(modItem.order), name: \(modItem.modName)")
        }
      }
      save()
      updateOrderOfModItems()
      
      offsetsToDelete = nil
      modItemToDelete = nil
      
      if let index = indexToSelect {
        DispatchQueue.main.asyncAfter(deadline: .now() + UIDELAY) {
          selectModItem(modItems[index - 1])
          Debug.log("Selected mod item order after deletion: \(modItems[index - 1])")
        }
      }
    }
  }
  
  private func updateOrderOfModItems() {
    var updatedOrder = 0
    for item in modItems.sorted(by: { $0.order < $1.order }) {
      item.order = updatedOrder
      Debug.log("Updated order for item \(item.modName) to \(updatedOrder)")
      updatedOrder += 1
    }
    save()
  }
  
  private func nextOrderValue() -> Int {
    if modItems.isEmpty {
      return 0  // If there are no items, start with 0
    } else {
      // Otherwise, find the maximum order and add 1
      return (modItems.max(by: { $0.order < $1.order })?.order ?? 0) + 1
    }
  }
  
  private func importModFolderAndUpdateModItemDirectoryPath(at originalPath: URL, modItem: ModItem, progress: Binding<Double>, completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      self.isFileTransferInProgress = true
    }
    
    importModFolderAndReturnNewDirectoryPath(
      at: originalPath,
      progressHandler: { progressValue in
        DispatchQueue.main.async {
          progress.wrappedValue = progressValue.fractionCompleted
        }
      },
      completionHandler: { directoryPath in
        DispatchQueue.main.async {
          if let directoryPath = directoryPath {
            modItem.directoryUrl = URL(fileURLWithPath: directoryPath)
            modItem.directoryPath = directoryPath
          } else {
            showToastError("Unable to resolve directoryPath from importModFolderAndReturnNewDirectoryPath(at: \(originalPath))")
          }
          self.isFileTransferInProgress = false
          SoundUtility.play(systemSound: .mount)
          showToastSuccess("Mod successfully added")
          if (!Debug.fileTransferUI) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              self.fileTransferProgress = 0
            }
          }
          completion()
        }
      }
    )
  }
  
  private func importModFolderAndReturnNewDirectoryPath(at originalPath: URL, progressHandler: @escaping (Progress) -> Void, completionHandler: @escaping (String?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let fileManager = FileManager.default
      guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        DispatchQueue.main.async {
          completionHandler(nil)
        }
        return
      }
      
      let destinationURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.UserModsFolderName).appendingPathComponent(originalPath.lastPathComponent)
      let progress = Progress(totalUnitCount: 1)
      
      do {
        if UserSettings.shared.makeCopyOfModFolderOnImport {
          progressHandler(progress)
          try fileManager.copyItem(at: originalPath, to: destinationURL)
        } else {
          progressHandler(progress)
          try fileManager.moveItem(at: originalPath, to: destinationURL)
        }
        
        progress.completedUnitCount = 1
        DispatchQueue.main.async {
          completionHandler(destinationURL.path)
        }
      } catch {
        DispatchQueue.main.async {
          showToastError("Unable to manage mod folder", withLogDetails: error.localizedDescription)
          completionHandler(nil)
        }
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: ModItem.self, inMemory: true)
}
