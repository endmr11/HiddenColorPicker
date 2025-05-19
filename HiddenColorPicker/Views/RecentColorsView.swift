//
//  RecentColorsView.swift
//  HiddenColorPicker
//
//  Created by Eren on 19.05.2025.
//

import SwiftUI
import AppKit
import UserNotifications

struct RecentColorsView: View {
    @State private var recentColors: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last Selected Colors")
                .font(.headline)
                .padding(.bottom, 5)
            
            if recentColors.isEmpty {
                Text("No color selected yet")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                        ForEach(recentColors, id: \.self) { hexColor in
                            ColorItemView(hexColor: hexColor)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                HStack {
                    Spacer()
                    Button("Clear") {
                        UserPreferences.shared.clearRecentColors()
                        updateRecentColors()
                    }
                    .disabled(recentColors.isEmpty)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .frame(width: 300, height: 300)
        .onAppear {
            updateRecentColors()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("RecentColorsUpdated"),
                                                  object: nil, 
                                                  queue: .main) { _ in
                updateRecentColors()
            }
        }
    }
    
    private func updateRecentColors() {
        recentColors = UserPreferences.shared.recentColors
    }
}

struct ColorItemView: View {
    let hexColor: String
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(ColorUtils.color(from: hexColor) ?? .gray)
                    .frame(width: 40, height: 40)
                    .shadow(radius: isHovering ? 3 : 1)
                
                if isHovering {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                }
            }
            .onHover { hovering in
                isHovering = hovering
            }
            .onTapGesture {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(hexColor, forType: .string)
                
                UserPreferences.shared.showNotification(title: "Color Copied", message: hexColor)
            }
            
            Text(hexColor)
                .font(.system(size: 9))
                .lineLimit(1)
        }
    }
}

#Preview {
    RecentColorsView()
} 
