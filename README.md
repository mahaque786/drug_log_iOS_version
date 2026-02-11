# MedRef — Medication Reference Guide (iOS)

A native SwiftUI iOS app for browsing medications, viewing pharmacological details, and logging doses with safety warnings. Connects to your existing Google Apps Script backend.

## Requirements

- **macOS** with **Xcode 15+** installed (free from the Mac App Store)
- iOS 17+ deployment target (runs on iPhone and iPad)
- Apple Developer account (free tier works for running on your own device)

---

## Setup Instructions

### 1. Create the Xcode Project

1. Open **Xcode** → **File → New → Project**
2. Choose **iOS → App** → click **Next**
3. Fill in:
   - **Product Name:** `MedRef`
   - **Organization Identifier:** e.g. `com.yourname` (anything works)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - Leave "Include Tests" unchecked (optional)
4. Click **Next**, choose a save location, and click **Create**

### 2. Replace the Default Files

Xcode generates some starter files. Replace/add as follows:

1. **Delete** the auto-generated `ContentView.swift` (you'll replace it)
2. **Delete** the auto-generated `MedRefApp.swift` (you'll replace it)
3. **Drag all 8 `.swift` files** from this folder into the `MedRef` group in Xcode's file navigator:
   - `MedRefApp.swift`
   - `ContentView.swift`
   - `Models.swift`
   - `MedicationStore.swift`
   - `MedicationListView.swift`
   - `MedicationDetailView.swift`
   - `DoseLoggerView.swift`
   - `LogHistoryView.swift`
   - `SettingsView.swift`
4. When prompted, check **"Copy items if needed"** and make sure **"Add to target: MedRef"** is checked

### 3. Add the Data File

1. **Drag `medlist.json`** into the `MedRef` group in Xcode
2. Make sure **"Copy items if needed"** is checked
3. Make sure **"Add to target: MedRef"** is checked
4. Verify it appears in **Build Phases → Copy Bundle Resources** (it should be added automatically)

### 4. Configure App Transport Security (for Google Apps Script)

The app needs to reach `script.google.com`. This should work by default since it's HTTPS, but if you encounter network issues:

1. Open `Info.plist` (or the Info tab in your target settings)
2. Ensure there's no restrictive ATS configuration blocking the request

### 5. Run It

1. Select a **Simulator** (e.g., iPhone 16) or connect a physical device
2. Press **⌘R** (or click the ▶ Play button)
3. The app will build and launch

---

## Running on a Physical Device

1. In Xcode, go to **Xcode → Settings → Accounts** and sign in with your Apple ID
2. Select your project in the navigator → select the **MedRef** target → **Signing & Capabilities**
3. Choose your **Team** from the dropdown
4. Connect your iPhone via USB/Lightning
5. On first run, go to **Settings → General → VPN & Device Management** on your iPhone and trust the developer certificate
6. Press **⌘R** to build and run

---

## Project Structure

```
MedRef/
├── MedRefApp.swift              # App entry point
├── ContentView.swift            # Tab bar (Medications / Log Dose / History / Settings)
├── Models.swift                 # Data models (Medication, DoseLog, etc.)
├── MedicationStore.swift        # Central state: loads JSON, evaluates warnings, network calls
├── MedicationListView.swift     # Searchable medication list
├── MedicationDetailView.swift   # Full detail view for a single medication
├── DoseLoggerView.swift         # Dose logging form with safety warnings
├── LogHistoryView.swift         # Chronological list of logged doses
├── SettingsView.swift           # Apps Script URL configuration & app info
└── medlist.json                 # Bundled medication data
```

## Features

| Feature | Description |
|---|---|
| **Medication Browser** | Searchable list of all medications with full pharmacological details |
| **Detail View** | Doses, half-life, mechanism of action, on/off-label uses, drug interactions, citations |
| **Dose Logger** | Pick medication → dose → units → reason, then log to Google Sheets |
| **Safety Warnings** | Checks for too-soon dosing, daily max exceeded, dangerous interactions, colestipol timing |
| **Log History** | View all logged doses sorted by time |
| **Google Sheets Sync** | Reads/writes dose logs via your existing Apps Script backend |

## Google Apps Script

The app ships with your existing Apps Script URL pre-configured. You can change it in the **Settings** tab at any time. The API contract is the same as your web app:

- **GET** `?action=logs` → returns `{ success: true, logs: [...] }`
- **POST** body `{ action: "log", medicationName, dose, reason }` → returns `{ success: true, logged: {...} }`
