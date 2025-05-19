# HiddenColorPicker

**HiddenColorPicker** is a lightweight macOS menu bar application that lets you instantly pick the color of any pixel under your mouse cursor and copy its hex code to your clipboard. The app runs discreetly in the menu bar and does not appear in the Dock.

## Features

- **Menu Bar Only:** Runs in the menu bar, not in the Dock.
- **Global Hotkey:** Instantly pick a color from anywhere on your screen using a customizable keyboard shortcut.
- **Recent Colors:** Keeps a history of your recently picked colors for quick access.
- **Clipboard Copy:** Automatically copies the selected color's hex code to your clipboard.
- **User Notifications:** Notifies you when a color is copied or if an error occurs.
- **Screen Recording Permission Handling:** Guides you to enable the necessary permissions for color picking.

## Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/HiddenColorPicker.git
   ```
2. **Open in Xcode:**
   - Open `HiddenColorPicker.xcodeproj` in Xcode.
3. **Build & Run:**
   - Build and run the app on your Mac.

## Usage

- Click the eyedropper icon in the menu bar to pick a color.
- Use the global hotkey (default: <kbd>⌘</kbd> + <kbd>⌥</kbd> + <kbd>C</kbd>) to pick a color instantly.
- Access recent colors and settings from the menu bar.
- The app will prompt you to grant screen recording permission if needed.

## Customization

- **Change Hotkey:** Open the Settings window from the menu bar to customize the global shortcut.
- **Notifications:** Enable or disable notifications in the Settings.
- **Recent Colors:** View or clear your recent color history.

## Permissions

The app requires **Screen Recording** permission to read pixel data from your screen. You will be prompted to grant this permission on first use.

## Development

- Written in Swift and SwiftUI.
- Uses `ScreenCaptureKit` and `CoreGraphics` for pixel color detection.
- Compatible with macOS 13+.

## License

MIT License. See [LICENSE](LICENSE) for details. 