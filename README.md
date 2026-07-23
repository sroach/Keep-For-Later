# KeepForLater

KeepForLater is a SwiftUI-based iOS and iPadOS app designed to help you quickly save URLs, text snippets, and notes for later reading. It features offline-first storage using SwiftData and supports data portability via JSON import/export.

## Setup Instructions

1. **Open the Project**: Open `Keep For Later.xcodeproj` in Xcode 15 or later.
2. **Configure App Groups**:
   - To enable sharing between the main app and the Share Extension, you must create an App Group.
   - Go to the **Capabilities** tab for the main app target.
   - Add the **App Groups** capability.
   - Add a new group (e.g., `group.yourname.keepforlater`).
   - Update `SharedContainer.swift` with your new App Group ID:
     ```swift
     static let appGroupIdentifier = "group.yourname.keepforlater"
     ```
3. **Add Share Extension Target** (If not already present):
   - Go to **File > New > Target...**
   - Select **Share Extension**.
   - Name it `KeepForLaterShare`.
   - Ensure the new target also has the **App Groups** capability enabled with the same ID.
   - Link the source files from `Keep For Later/Extensions` to this new target.

## Entitlements & Capabilities

- **App Groups**: Required for data sharing between the app and the Share Extension.
- **Network**: Required to open URLs in `SFSafariViewController`.

## Known Limitations

- **MVP Phase**: Currently supports local storage only; no iCloud sync.
- **Deduplication**: Deduplication is based on a deterministic hash of the URL, Snippet, and Note. Small changes in whitespace or formatting might result in duplicates if not normalized.
- **Share Extension**: The current project structure includes the source files for a Share Extension handler, but the target must be manually configured in Xcode to be active.

## Next Steps

- **iCloud Sync**: Integrate CloudKit for automatic synchronization across devices.
- **Encryption**: Add on-device encryption for sensitive notes.
- **Biometric Lock**: Implement FaceID/TouchID lock for the app.
- **Tag Management**: Add a dedicated screen for managing and renaming tags.
- **Browser Extension**: Develop a companion extension for desktop browsers.
