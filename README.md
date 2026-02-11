# Drug Log - iOS Application

A medication tracking and logging application for iOS built with SwiftUI.

## Overview

Drug Log is an iOS application designed to help users track their medications, set reminders, and monitor medication adherence. This repository contains the foundational structure for the iOS app.

## Features

- 📊 Track medication schedules
- ⏰ Set medication reminders
- 📈 View medication history
- ❤️ Monitor adherence patterns
- 💾 Local data persistence

## Project Structure

```
DrugLog/
├── DrugLog/
│   ├── DrugLogApp.swift       # Main app entry point
│   ├── Models/                # Data models
│   │   ├── DrugEntry.swift    # Medication entry model
│   │   └── DrugLogStore.swift # Data persistence layer
│   ├── Views/                 # SwiftUI views
│   │   └── ContentView.swift  # Main view
│   ├── Resources/             # Assets and resources
│   └── Info.plist            # App configuration
└── DrugLogTests/             # Unit tests
```

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Getting Started

### Building with Xcode

1. Clone the repository:
   ```bash
   git clone https://github.com/mahaque786/drug_log_iOS_version.git
   cd drug_log_iOS_version
   ```

2. Open the project in Xcode or use Swift Package Manager

3. Build and run the project on a simulator or device

### Using Swift Package Manager

```bash
swift build
swift test
```

## Architecture

The app follows a simple MVVM architecture:

- **Models**: Data structures for medication entries and persistence
- **Views**: SwiftUI views for the user interface
- **Store**: Observable data store for state management

## Data Persistence

The app uses local JSON file storage to persist medication data. All data is stored securely in the app's document directory with file protection enabled.

## Contributing

This is the foundation for the Drug Log iOS application. Future enhancements will include:

- User notifications for medication reminders
- Calendar integration
- Statistics and insights
- Export functionality
- Multiple user profiles

## License

This project is part of a personal medication tracking solution.

## Contact

For questions or suggestions, please open an issue in the repository.