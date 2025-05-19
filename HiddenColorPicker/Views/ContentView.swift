//
//  ContentView.swift
//  HiddenColorPicker
//
//  Created by Eren on 19.05.2025.
//

import SwiftUI
import AppKit
import UserNotifications

struct ContentView: View {
    @State private var recentColors = UserPreferences.shared.recentColors
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "eyedropper")
                .imageScale(.large)
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            
            Text("HiddenColorPicker")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Capture color from any point on your screen")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.vertical)
            
            HStack {
                Text("Shortcut:")
                    .fontWeight(.bold)
                
                Text(UserPreferences.shared.getReadableShortcut())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            VStack(alignment: .leading) {
                Text("Last Selected Colors")
                    .font(.headline)
                    .padding(.top, 10)
                
                if recentColors.isEmpty {
                    Text("No color selected yet")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(recentColors.prefix(10), id: \.self) { hexColor in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ColorUtils.color(from: hexColor) ?? .gray)
                                        .frame(width: 30, height: 30)
                                        .shadow(radius: 1)
                                    
                                    Text(hexColor)
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .onTapGesture {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(hexColor, forType: .string)
                                    UserPreferences.shared.showNotification(title: "Color Copied", message: hexColor)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("To change the shortcut settings, click on the icon in the menu bar and select 'Settings'.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 400)
        .onAppear {
            updateRecentColors()
            NotificationCenter.default.addObserver(forName: NSNotification.Name("RecentColorsUpdated"),object: nil,queue: .main) { _ in
                updateRecentColors()
            }
        }
    }
    
    private func updateRecentColors() {
        recentColors = UserPreferences.shared.recentColors
    }
}

#Preview {
    ContentView()
}
