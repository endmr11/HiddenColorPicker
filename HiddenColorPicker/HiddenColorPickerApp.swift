//
//  HiddenColorPickerApp.swift
//  HiddenColorPicker
//
//  Created by Eren on 19.05.2025.
//

import SwiftUI
import AppKit
import Carbon
import Cocoa
import ScreenCaptureKit
import AVFoundation
import CoreGraphics
import UserNotifications

@main
struct HiddenColorPickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow?
    var recentColorsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            if let appIcon = NSImage(named: "AppIcon") {
                appIcon.size = NSSize(width: 18, height: 18)
                button.image = appIcon
            }
            button.action = #selector(showMenu(_:))
        }
        constructMenu()
        HotKeyManager.shared.registerHotKey()
        
        checkScreenRecordingPermission()
        
        requestNotificationPermissions()
    }

    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Pick Color", action: #selector(pickColor), keyEquivalent: ""))
        updateColorMenuItemShortcut(menu.items.first)
        
        menu.addItem(.separator())
        
        menu.addItem(NSMenuItem(title: "Latest Colors", action: #selector(showRecentColors), keyEquivalent: "r"))
        menu.items.last?.keyEquivalentModifierMask = .command
        
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ","))
        menu.items.last?.keyEquivalentModifierMask = .command
        
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func updateColorMenuItemShortcut(_ menuItem: NSMenuItem?) {
        guard let menuItem = menuItem else { return }
        
        let prefs = UserPreferences.shared
        let keyCode = prefs.shortcutKeyCode
        
        if let keyString = prefs.getReadableShortcut().last?.description {
            menuItem.keyEquivalent = keyString.lowercased()
            
            let modifiers = prefs.shortcutModifier
            var modifierMask: NSEvent.ModifierFlags = []
            if (modifiers & UInt32(cmdKey)) != 0 { modifierMask.insert(.command) }
            if (modifiers & UInt32(optionKey)) != 0 { modifierMask.insert(.option) }
            if (modifiers & UInt32(controlKey)) != 0 { modifierMask.insert(.control) }
            if (modifiers & UInt32(shiftKey)) != 0 { modifierMask.insert(.shift) }
            
            menuItem.keyEquivalentModifierMask = modifierMask
        }
    }

    @objc func showMenu(_ sender: Any?) {
        statusItem.button?.performClick(nil)
    }

    @objc func pickColor() {
        ColorPicker.shared.captureMouseColor()
    }
    
    @objc func showRecentColors() {
        if recentColorsWindow == nil || recentColorsWindow?.contentView == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "Last Selected Colors"
            window.center()
            
            let recentColorsView = RecentColorsView()
            let hostingView = NSHostingView(rootView: recentColorsView)
            hostingView.autoresizingMask = [.width, .height]
            hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 300)
            
            window.contentView = hostingView
            
            window.isReleasedWhenClosed = false
            window.delegate = self
            
            recentColorsWindow = window
        }
        
        recentColorsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func showSettings() {
        if settingsWindow == nil || settingsWindow?.contentView == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "HiddenColorPicker Settings"
            window.center()
            
            let settingsView = SettingsView()
            let hostingView = NSHostingView(rootView: settingsView)
            hostingView.autoresizingMask = [.width, .height]
            hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
            
            window.contentView = hostingView
            
            window.isReleasedWhenClosed = false
            window.delegate = self
            
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    private func checkScreenRecordingPermission() {
        let screenRecordingAuthStatus = CGPreflightScreenCaptureAccess()
        if !screenRecordingAuthStatus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let alert = NSAlert()
                alert.messageText = "Screen Recording Permission Required"
                alert.informativeText = "HiddenColorPicker app needs screen recording permission to capture colors on your screen. Please grant permission in System Settings > Privacy & Security > Screen Recording."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Cancel")
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    CGRequestScreenCaptureAccess()
                    
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error notification permission request: \(error.localizedDescription)")
            }
        }
    }
    
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == recentColorsWindow {
                recentColorsWindow = nil
            } else if window == settingsWindow {
                settingsWindow = nil
            }
        }
    }
}

class HotKeyManager {
    static let shared = HotKeyManager()
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {}

    func registerHotKey() {
        unregisterHotKey()
        
        let keyCode = UserPreferences.shared.shortcutKeyCode
        let modifiers = UserPreferences.shared.shortcutModifier
        
        var gMyHotKeyID = EventHotKeyID(signature: OSType(UInt32(truncatingIfNeeded: "CPHK".hashValue)), id: 1)
        
        RegisterEventHotKey(keyCode, modifiers, gMyHotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)

        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            var hkCom = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout.size(ofValue: hkCom), nil, &hkCom)
            if hkCom.id == 1 {
                ColorPicker.shared.captureMouseColor()
            }
            return noErr
        }, 1, [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))], nil, nil)
    }
    
    func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}


class ColorPicker: NSObject {
    static let shared = ColorPicker()
    private override init() {}

    private var stream: SCStream?
    private var streamOutput: SCStreamOutput?
    private var continuation: CheckedContinuation<String, Never>?
    private var debugWindow: NSWindow?
    private var isCapturing = false

    func captureMouseColor() {
        if isCapturing {
            return
        }
        isCapturing = true
        
        showMouseIndicator()
        
        Task {
            let hex = await grabPixelColorAtMouse()
            
            DispatchQueue.main.async { [weak self] in
                self?.hideMouseIndicator()
                self?.isCapturing = false
            }
            
            if hex != "#000000" {
                copyToClipboard(hex)
                UserPreferences.shared.addRecentColor(hex)
                NotificationCenter.default.post(name: NSNotification.Name("RecentColorsUpdated"), object: nil)
                showUserNotification("Color Copied", message: hex)
            } else {
                showUserNotification("Error", message: "Color not retrieved. Please try again..")
            }
        }
    }
    
    private func showMouseIndicator() {
        hideMouseIndicator()
        DispatchQueue.main.async { [weak self] in
            let mouseLocation = NSEvent.mouseLocation
            let window = NSWindow(
                contentRect: NSRect(x: mouseLocation.x - 15, y: mouseLocation.y - 15, width: 30, height: 30),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.backgroundColor = .clear
            window.isOpaque = false
            window.level = .floating
            window.ignoresMouseEvents = true
            let circleView = NSView(frame: NSRect(x: 0, y: 0, width: 30, height: 30))
            circleView.wantsLayer = true
            circleView.layer?.backgroundColor = NSColor.clear.cgColor
            let circleLayer = CAShapeLayer()
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: 0, y: 0, width: 30, height: 30))
            circleLayer.path = path
            circleLayer.fillColor = NSColor.clear.cgColor
            circleLayer.strokeColor = NSColor.yellow.cgColor
            circleLayer.lineWidth = 2.0
            circleView.layer?.addSublayer(circleLayer)
            window.contentView = circleView
            window.orderFront(nil)
            self?.debugWindow = window
        }
    }
    
    private func hideMouseIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.debugWindow?.orderOut(nil)
            self?.debugWindow = nil
        }
    }

    private func grabPixelColorAtMouse() async -> String {
        if let existingStream = self.stream {
            try? await existingStream.stopCapture()
            self.stream = nil
        }
        
        let mouseLocation = NSEvent.mouseLocation
        
        guard let currentScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) else {
            return "#000000"
        }
        
        guard let content = try? await SCShareableContent.current else {
            checkScreenRecordingPermission()
            return "#000000"
        }
        
        var targetDisplay: SCDisplay? = nil
        for display in content.displays {
            let displayFrame = display.frame
            if displayFrame.origin.x == currentScreen.frame.origin.x &&
               displayFrame.origin.y == currentScreen.frame.origin.y &&
               Int(displayFrame.width) == Int(currentScreen.frame.width) &&
               Int(displayFrame.height) == Int(currentScreen.frame.height) {
                targetDisplay = display
                break
            }
        }
        
        if targetDisplay == nil {
            var closestDisplay = content.displays.first
            var minDistance = Double.greatestFiniteMagnitude
            
            for display in content.displays {
                let displayCenter = CGPoint(
                    x: display.frame.origin.x + display.frame.width / 2,
                    y: display.frame.origin.y + display.frame.height / 2
                )
                let distance = hypot(mouseLocation.x - displayCenter.x, mouseLocation.y - displayCenter.y)
                
                if distance < minDistance {
                    minDistance = distance
                    closestDisplay = display
                }
            }
            
            targetDisplay = closestDisplay
        }
        
        guard let display = targetDisplay else {
            return "#000000"
        }
        
        let config = SCStreamConfiguration()
        config.width = display.width
        config.height = display.height
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.capturesAudio = false
        config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        config.showsCursor = false
        
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        
        do {
            let stream = SCStream(filter: filter, configuration: config, delegate: self)
            self.stream = stream
            
            try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: DispatchQueue.main)
            
            try await stream.startCapture()
            
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    guard let self = self else { return }
                    
                    if let cont = self.continuation {
                        cont.resume(returning: "#000000")
                        self.continuation = nil
                        
                        Task {
                            try? await self.stream?.stopCapture()
                            self.stream = nil
                        }
                    }
                }
            }
        } catch {
            checkScreenRecordingPermission()
            return "#000000"
        }
    }
    
    private func checkScreenRecordingPermission() {
        let screenRecordingAuthStatus = CGPreflightScreenCaptureAccess()
        if !screenRecordingAuthStatus {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Screen Recording Permission Required"
                alert.informativeText = "HiddenColorPicker app needs screen recording permission to capture colors on your screen. Please grant permission in System Settings > Privacy & Security > Screen Recording."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Cancel")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    CGRequestScreenCaptureAccess()
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }

    private func copyToClipboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }

    private func showUserNotification(_ title: String, message: String) {
        UserPreferences.shared.showNotification(title: title, message: message)
    }
}

extension ColorPicker: SCStreamDelegate, SCStreamOutput {
    @objc(stream:didOutputSampleBuffer:ofType:)
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { 
            DispatchQueue.main.async { [weak self] in
                self?.continuation?.resume(returning: "#000000")
                self?.continuation = nil
            }
            return 
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
            Task { [weak self] in
                guard let self = self else { return }
                try? await self.stream?.stopCapture()
                self.stream = nil
            }
        }
        
        let base = CVPixelBufferGetBaseAddress(imageBuffer)!
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let mouseLocation = NSEvent.mouseLocation
        
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) else {
            DispatchQueue.main.async { [weak self] in
                self?.continuation?.resume(returning: "#000000")
                self?.continuation = nil
            }
            return
        }
        
        let screenFrame = screen.frame
        
        let relativeX = mouseLocation.x - screenFrame.origin.x
        let relativeY = screenFrame.height - (mouseLocation.y - screenFrame.origin.y)
        
        let x = Int(relativeX)
        let y = Int(relativeY)
        
        if x >= 0 && x < width && y >= 0 && y < height {
            let offset = y * bytesPerRow + x * 4
            
            let b = base.load(fromByteOffset: offset + 0, as: UInt8.self)
            let g = base.load(fromByteOffset: offset + 1, as: UInt8.self)
            let r = base.load(fromByteOffset: offset + 2, as: UInt8.self)
            
            let hex = String(format: "#%02X%02X%02X", r, g, b)
            
            for dy in -1...1 {
                for dx in -1...1 {
                    if dx == 0 && dy == 0 { continue }
                    
                    let nx = x + dx
                    let ny = y + dy
                    
                    if nx >= 0 && nx < width && ny >= 0 && ny < height {
                        let noffset = ny * bytesPerRow + nx * 4
                        let nb = base.load(fromByteOffset: noffset + 0, as: UInt8.self)
                        let ng = base.load(fromByteOffset: noffset + 1, as: UInt8.self)
                        let nr = base.load(fromByteOffset: noffset + 2, as: UInt8.self)
                        let nhex = String(format: "#%02X%02X%02X", nr, ng, nb)
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.continuation?.resume(returning: hex)
                self?.continuation = nil
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.continuation?.resume(returning: "#000000")
                self?.continuation = nil
            }
        }
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.continuation?.resume(returning: "#000000")
            self?.continuation = nil
            self?.stream = nil
        }
    }
}
