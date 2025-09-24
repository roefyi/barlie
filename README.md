# Barlie - Beer Rating App

A modern iOS beer rating and discovery app built with SwiftUI, inspired by Letterboxd and Untappd.

## 🍺 Features

- **Discover Tab**: Browse and search for beers with "For You" and "Most Liked" sections
- **My Barlie Tab**: Personal profile with beer collections, ratings, and lists
- **Modern UI**: Deep black background with clean, minimal design inspired by Cosmos app
- **Swipeable Tabs**: Intuitive navigation with swipe gestures
- **Full-Screen Search**: iOS-native search experience with keyboard integration
- **Dynamic Headers**: Profile information that adapts when scrolling
- **Beer Rating System**: Rate beers with stars and add reviews

## 🎨 Design

- **Color Scheme**: Deep black background with white text and icons
- **Typography**: iOS system fonts with proper sizing hierarchy
- **Animations**: Smooth transitions and spring animations
- **Layout**: Edge-to-edge cards with proper spacing and padding

## 🛠 Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **iOS 15.0+**: Minimum deployment target
- **MVVM Architecture**: Clean separation of concerns
- **Combine**: Reactive programming for data flow

## 📱 Screenshots

The app features:
- Discover page with beer cards and search functionality
- Profile page with user stats and beer collections
- Swipeable tab navigation
- Full-screen search overlays
- Dynamic scroll headers

## 🚀 Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- macOS 12.0 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/barlie.git
cd barlie
```

2. Open the project in Xcode:
```bash
open barlie/barlie.xcodeproj
```

3. Select a simulator or device and run the app (⌘+R)

## 📁 Project Structure

```
barlie/
├── barlie/
│   ├── Models/
│   │   └── Beer.swift              # Data models
│   ├── Views/
│   │   ├── DiscoverView.swift      # Discover tab
│   │   ├── MyBarlieView.swift      # Profile tab
│   │   └── BeerRatingView.swift    # Beer rating interface
│   ├── ViewModels/
│   │   ├── DiscoverViewModel.swift # Discover logic
│   │   └── MyBarlieViewModel.swift # Profile logic
│   ├── Utilities/
│   │   ├── AnimationExtensions.swift # Custom animations
│   │   └── CustomTabBar.swift      # Tab navigation
│   ├── Assets.xcassets/            # App icons and colors
│   ├── BarlieApp.swift            # App entry point
│   ├── ContentView.swift          # Root view
│   └── Info.plist                 # App configuration
└── README.md
```

## 🎯 Key Features

### Discover Tab
- Search for beers by name, brewery, or style
- "For You" personalized recommendations
- "Most Liked" popular beers
- Swipeable tab navigation
- Full-screen search with iOS keyboard

### My Barlie Tab
- User profile with stats
- Beer collections (Next, Drank, Lists)
- Dynamic scroll header
- Action buttons (Activity, Share, Settings)
- Custom beer lists

### Design System
- Deep black background (#000000)
- White text and icons for contrast
- System gray colors for secondary elements
- Proper iOS spacing and typography
- Smooth animations and transitions

## 🔧 Development

### Building for Simulator
```bash
xcodebuild build -project barlie/barlie.xcodeproj -scheme barlie -destination "platform=iOS Simulator"
```

### Building for Device
Requires proper code signing and provisioning profiles.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

If you have any questions or need help, please open an issue on GitHub.

---

Built with ❤️ using SwiftUI
