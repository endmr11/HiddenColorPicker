//
//  SettingsView.swift
//  HiddenColorPicker
//
//  Created by Eren on 19.05.2025.
//

import SwiftUI
import Carbon
import AppKit

struct SettingsView: View {
    @State private var isRecordingShortcut = false
    @State private var currentShortcut = UserPreferences.shared.getReadableShortcut()
    @State private var tempModifiers: UInt32 = 0
    @State private var tempKeyCode: UInt32 = 0
    @State private var notificationsEnabled = UserPreferences.shared.notificationsEnabled
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Shortcut Settings")
                .font(.headline)
            
            HStack {
                Text("Current Shortcut:")
                
                if isRecordingShortcut {
                    Text("Enter the key combination...")
                        .foregroundColor(.gray)
                        .frame(width: 200, height: 30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    Text(currentShortcut)
                        .frame(width: 200, height: 30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Button(isRecordingShortcut ? "Cancel" : "Change") {
                    isRecordingShortcut.toggle()
                    if !isRecordingShortcut {
                        tempModifiers = 0
                        tempKeyCode = 0
                    }
                }
            }
            
            Divider()
            
            Toggle("Show Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { newValue in
                    UserPreferences.shared.notificationsEnabled = newValue
                }
            
            Text("Notification is shown when color is selected and copied.")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Divider()
            
            HStack {
                Button("Reset to Default") {
                    UserPreferences.shared.resetToDefault()
                    currentShortcut = UserPreferences.shared.getReadableShortcut()
                    
                    updateShortcut()
                }
                
                Spacer()
                
                Button("Save") {
                    if tempKeyCode != 0 && tempModifiers != 0 {
                        UserPreferences.shared.shortcutKeyCode = tempKeyCode
                        UserPreferences.shared.shortcutModifier = tempModifiers
                        currentShortcut = UserPreferences.shared.getReadableShortcut()
                        updateShortcut()
                    }
                    
                    isRecordingShortcut = false
                    tempKeyCode = 0
                    tempModifiers = 0
                }
                .disabled(!isRecordingShortcut || tempKeyCode == 0)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if isRecordingShortcut {
                    tempModifiers = 0
                    if event.modifierFlags.contains(.command) {
                        tempModifiers |= UInt32(cmdKey)
                    }
                    if event.modifierFlags.contains(.option) {
                        tempModifiers |= UInt32(optionKey)
                    }
                    if event.modifierFlags.contains(.control) {
                        tempModifiers |= UInt32(controlKey)
                    }
                    if event.modifierFlags.contains(.shift) {
                        tempModifiers |= UInt32(shiftKey)
                    }
                    tempKeyCode = UInt32(event.keyCode)
                    updateTempShortcutDisplay()
                    return nil
                }
                return event
            }
        }
    }
    
    private func updateTempShortcutDisplay() {
        var modifierString = ""
        
        if (tempModifiers & UInt32(cmdKey)) != 0 { modifierString += "⌘" }
        if (tempModifiers & UInt32(optionKey)) != 0 { modifierString += "⌥" }
        if (tempModifiers & UInt32(controlKey)) != 0 { modifierString += "⌃" }
        if (tempModifiers & UInt32(shiftKey)) != 0 { modifierString += "⇧" }
        
        if let keyString = keyCodeToString(keyCode: tempKeyCode) {
            currentShortcut = modifierString + keyString
        }
    }
    
    private func keyCodeToString(keyCode: UInt32) -> String? {
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
    
    private func updateShortcut() {
        HotKeyManager.shared.unregisterHotKey()
        HotKeyManager.shared.registerHotKey()
        
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.constructMenu()
        }
    }
} 
