//
//  Debug.swift
//  BaldursModManager
//
//  Created by Justin Bush on 2/5/24.
//

import Foundation

/// A debugging utility class that conditionally performs logging and actions based on its active state.
///
/// This class provides a global access point through `Debug.shared` to perform logging and execute closures conditionally if debugging is enabled.
@Observable
class Debug {
  /// The singleton instance for global access.
  static let shared = Debug()
  static var fileTransferUI = false
  static var permissionsView = false
  
  var logModItems = false
  
  var sessionLog = ""
  
  private func appendToSessionLog<T>(_ value: T) {
    if value is String {
      sessionLog += "\(value)\n"
    }
  }
  
  /// Indicates whether debugging actions should be performed.
  var isActive = false
  
  /// Logs a given value to the console if debugging is active.
  ///
  /// Use this instance method to log any value (e.g., String, Int) when debugging is enabled.
  ///
  /// - Parameter value: The value to be logged.
  ///
  /// **Usage:**
  ///
  /// ```swift
  /// Debug.shared.logInstance("Debugging started")
  /// ```
  ///
  /// - important: Use `Debug.log` instead.
  private func logInstance<T>(_ value: T) {
    appendToSessionLog(value)
    if isActive {
      print(value)
    }
  }
  
  /// Logs a given value to the console if debugging is active.
  ///
  /// Use this static method to log any value conveniently without needing direct access to the `Debug` singleton.
  ///
  /// - Parameter value: The value to be logged.
  ///
  /// **Usage:**
  ///
  /// ```swift
  /// Debug.log("User login attempt")
  /// ```
  static func log<T>(_ value: T) {
    Debug.shared.logInstance(value)
  }
  /// Executes a closure if debugging is active.
  ///
  /// This instance method conditionally performs the given action allowing for execution of debugging-specific tasks.
  ///
  /// - Parameter action: A closure to be executed if debugging is active.
  ///
  /// **Usage:**
  ///
  /// ```swift
  /// Debug.shared.perform {
  ///   print("Performing an action specific to debugging.")
  /// }
  /// ```
  ///
  /// - important: Use `Debug.perform` instead
  private func perform(action: () -> Void) {
    if isActive {
      action()
    }
  }
  
  /// Executes a closure if debugging is active.
  ///
  /// This static method provides a convenient way to execute debugging-specific tasks without needing direct access to the `Debug` singleton.
  ///
  /// - Parameter action: A closure to be executed if debugging is active.
  ///
  /// **Usage:**
  ///
  /// ```swift
  /// Debug.perform {
  ///   print("Performing an action specific to debugging.")
  /// }
  /// ```
  static func perform(action: @escaping () -> Void) {
    Debug.shared.perform(action: action)
  }
  
  static func logSection() {
    Debug.shared.appendToSessionLog("\n\n")
  }
  
  var simulateErrorToast: Bool = false
}
