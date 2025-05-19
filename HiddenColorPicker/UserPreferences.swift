//
//  UserPreferences.swift
//  HiddenColorPicker
//
//  Created by Eren on 19.05.2025.
//

import Foundation
import Carbon
import UserNotifications

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    private let keyModifierKey = "keyboardShortcutModifier"
    private let keyCodeKey = "keyboardShortcutKeyCode"
    private let recentColorsKey = "recentColors"
    private let notificationsEnabledKey = "notificationsEnabled"
    private let maxRecentColors = 10
    
    private let defaultModifier = UInt32(cmdKey | optionKey)
    private let defaultKeyCode = UInt32(kVK_ANSI_C)
    
    var shortcutModifier: UInt32 {
        get { UInt32(defaults.integer(forKey: keyModifierKey)) }
        set { defaults.set(Int(newValue), forKey: keyModifierKey) }
    }
    
    var shortcutKeyCode: UInt32 {
        get { UInt32(defaults.integer(forKey: keyCodeKey)) }
        set { defaults.set(Int(newValue), forKey: keyCodeKey) }
    }
    
    var recentColors: [String] {
        get { defaults.stringArray(forKey: recentColorsKey) ?? [] }
        set { defaults.set(newValue, forKey: recentColorsKey) }
    }
    
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: notificationsEnabledKey) }
        set { defaults.set(newValue, forKey: notificationsEnabledKey) }
    }
    
    private init() {
        if defaults.object(forKey: keyModifierKey) == nil {
            shortcutModifier = defaultModifier
        }
        
        if defaults.object(forKey: keyCodeKey) == nil {
            shortcutKeyCode = defaultKeyCode
        }
        
        if defaults.object(forKey: recentColorsKey) == nil {
            recentColors = []
        }
        
        if defaults.object(forKey: notificationsEnabledKey) == nil {
            notificationsEnabled = true
        }
    }
    
    func addRecentColor(_ hexColor: String) {
        var colors = recentColors
        
        if let index = colors.firstIndex(of: hexColor) {
            colors.remove(at: index)
        }
        
        colors.insert(hexColor, at: 0)
        
        if colors.count > maxRecentColors {
            colors.removeLast()
        }
        recentColors = colors
    }
    
    func clearRecentColors() {
        recentColors = []
    }
    
    func getReadableShortcut() -> String {
        let modifiers = shortcutModifier
        let keyCode = shortcutKeyCode
        
        var modifierString = ""
        
        if (modifiers & UInt32(cmdKey)) != 0 { modifierString += "⌘" }
        if (modifiers & UInt32(optionKey)) != 0 { modifierString += "⌥" }
        if (modifiers & UInt32(controlKey)) != 0 { modifierString += "⌃" }
        if (modifiers & UInt32(shiftKey)) != 0 { modifierString += "⇧" }
        
        let keyString = keyCodeToString(keyCode: keyCode) ?? "?"
        
        return modifierString + keyString
    }
    
    func keyCodeToString(keyCode: UInt32) -> String? {
        switch keyCode {
        case UInt32(kVK_ANSI_A): return "A"
        case UInt32(kVK_ANSI_B): return "B"
        case UInt32(kVK_ANSI_C): return "C"
        case UInt32(kVK_ANSI_D): return "D"
        case UInt32(kVK_ANSI_E): return "E"
        case UInt32(kVK_ANSI_F): return "F"
        case UInt32(kVK_ANSI_G): return "G"
        case UInt32(kVK_ANSI_H): return "H"
        case UInt32(kVK_ANSI_I): return "I"
        case UInt32(kVK_ANSI_J): return "J"
        case UInt32(kVK_ANSI_K): return "K"
        case UInt32(kVK_ANSI_L): return "L"
        case UInt32(kVK_ANSI_M): return "M"
        case UInt32(kVK_ANSI_N): return "N"
        case UInt32(kVK_ANSI_O): return "O"
        case UInt32(kVK_ANSI_P): return "P"
        case UInt32(kVK_ANSI_Q): return "Q"
        case UInt32(kVK_ANSI_R): return "R"
        case UInt32(kVK_ANSI_S): return "S"
        case UInt32(kVK_ANSI_T): return "T"
        case UInt32(kVK_ANSI_U): return "U"
        case UInt32(kVK_ANSI_V): return "V"
        case UInt32(kVK_ANSI_W): return "W"
        case UInt32(kVK_ANSI_X): return "X"
        case UInt32(kVK_ANSI_Y): return "Y"
        case UInt32(kVK_ANSI_Z): return "Z"
        case UInt32(kVK_ANSI_0): return "0"
        case UInt32(kVK_ANSI_1): return "1"
        case UInt32(kVK_ANSI_2): return "2"
        case UInt32(kVK_ANSI_3): return "3"
        case UInt32(kVK_ANSI_4): return "4"
        case UInt32(kVK_ANSI_5): return "5"
        case UInt32(kVK_ANSI_6): return "6"
        case UInt32(kVK_ANSI_7): return "7"
        case UInt32(kVK_ANSI_8): return "8"
        case UInt32(kVK_ANSI_9): return "9"
        case UInt32(kVK_Space): return "Space"
        default: return nil
        }
    }
    
    func stringToKeyCode(key: String) -> UInt32? {
        let uppercaseKey = key.uppercased()
        
        switch uppercaseKey {
        case "A": return UInt32(kVK_ANSI_A)
        case "B": return UInt32(kVK_ANSI_B)
        case "C": return UInt32(kVK_ANSI_C)
        case "D": return UInt32(kVK_ANSI_D)
        case "E": return UInt32(kVK_ANSI_E)
        case "F": return UInt32(kVK_ANSI_F)
        case "G": return UInt32(kVK_ANSI_G)
        case "H": return UInt32(kVK_ANSI_H)
        case "I": return UInt32(kVK_ANSI_I)
        case "J": return UInt32(kVK_ANSI_J)
        case "K": return UInt32(kVK_ANSI_K)
        case "L": return UInt32(kVK_ANSI_L)
        case "M": return UInt32(kVK_ANSI_M)
        case "N": return UInt32(kVK_ANSI_N)
        case "O": return UInt32(kVK_ANSI_O)
        case "P": return UInt32(kVK_ANSI_P)
        case "Q": return UInt32(kVK_ANSI_Q)
        case "R": return UInt32(kVK_ANSI_R)
        case "S": return UInt32(kVK_ANSI_S)
        case "T": return UInt32(kVK_ANSI_T)
        case "U": return UInt32(kVK_ANSI_U)
        case "V": return UInt32(kVK_ANSI_V)
        case "W": return UInt32(kVK_ANSI_W)
        case "X": return UInt32(kVK_ANSI_X)
        case "Y": return UInt32(kVK_ANSI_Y)
        case "Z": return UInt32(kVK_ANSI_Z)
        case "0": return UInt32(kVK_ANSI_0)
        case "1": return UInt32(kVK_ANSI_1)
        case "2": return UInt32(kVK_ANSI_2)
        case "3": return UInt32(kVK_ANSI_3)
        case "4": return UInt32(kVK_ANSI_4)
        case "5": return UInt32(kVK_ANSI_5)
        case "6": return UInt32(kVK_ANSI_6)
        case "7": return UInt32(kVK_ANSI_7)
        case "8": return UInt32(kVK_ANSI_8)
        case "9": return UInt32(kVK_ANSI_9)
        case "SPACE": return UInt32(kVK_Space)
        default: return nil
        }
    }
    
    func resetToDefault() {
        shortcutModifier = defaultModifier
        shortcutKeyCode = defaultKeyCode
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
    
    func showNotification(title: String, message: String) {
        if notificationsEnabled {
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, 
                                               content: content, 
                                               trigger: nil)
            
            center.add(request) { error in
                if let error = error {
                    print("Error adding notification: \(error.localizedDescription)")
                }
            }
        }
    }
} 
