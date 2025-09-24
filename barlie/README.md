# Barlie - iOS Beer Rating App

A native iOS app built with SwiftUI for discovering and rating beers, featuring smooth animations and a modern dark interface.

## Features

- **Discover Tab**: Search and browse beers by brewery, name, or style
- **My Barlie Tab**: Personal profile with stats, beer collections, and lists
- **Smooth Animations**: Custom transitions and haptic feedback
- **Dark Theme**: Modern iOS-style dark interface
- **Interactive Rating**: Star-based beer rating system with reviews

## Project Structure

```
barlie/
├── BarlieApp.swift              # Main app entry point
├── ContentView.swift            # Root view with tab navigation
├── Models/
│   └── Beer.swift              # Data models (Beer, BeerRating, BeerList)
├── Views/
│   ├── DiscoverView.swift      # Beer discovery and search
│   ├── MyBarlieView.swift      # User profile and collections
│   └── BeerRatingView.swift    # Beer rating interface
├── ViewModels/
│   ├── DiscoverViewModel.swift # Discover tab logic
│   └── MyBarlieViewModel.swift # Profile tab logic
├── Utilities/
│   ├── AnimationExtensions.swift # Custom animations
│   └── CustomTabBar.swift      # Animated tab bar
├── Info.plist                  # App configuration
└── README.md                   # This file
```

## Setup Instructions

### 1. Create New Xcode Project

1. Open Xcode
2. Create a new iOS project
3. Choose "App" template
4. Set project name to "Barlie"
5. Choose SwiftUI for interface
6. Set minimum deployment target to iOS 15.0

### 2. Add Files to Project

1. Copy all the Swift files from this directory into your Xcode project
2. Make sure to add them to the target
3. Organize files into groups as shown in the project structure

### 3. Configure Project Settings

1. Set the bundle identifier to your preference
2. Ensure iOS 15.0+ deployment target
3. Enable dark mode support in project settings

### 4. Build and Run

1. Select your target device or simulator
2. Press Cmd+R to build and run
3. The app should launch with the dark theme and animated tabs

## Key Features Implementation

### Animations
- Custom spring animations for smooth transitions
- Haptic feedback for user interactions
- Slide transitions between tabs
- Scale animations for interactive elements

### Data Models
- `Beer`: Core beer information
- `BeerRating`: User ratings and reviews
- `BeerList`: User-created beer collections

### View Models
- MVVM architecture for clean separation
- ObservableObject for reactive UI updates
- Sample data included for testing

### UI Components
- Custom tab bar with animations
- Beer cards with gradient backgrounds
- Star rating system
- Profile stats display
- List management interface

## Customization

### Colors
- Modify gradient colors in `BeerCardView` and `BeerGridView`
- Update accent colors in tab bar and buttons
- Adjust dark theme colors in view backgrounds

### Animations
- Customize animation timings in `AnimationExtensions.swift`
- Modify haptic feedback patterns
- Adjust transition effects

### Data
- Replace sample data in `Beer.sampleBeers`
- Add API integration for real beer data
- Implement Core Data for persistence

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Next Steps

1. Add Core Data for persistence
2. Integrate with beer API (e.g., BreweryDB, Untappd API)
3. Add social features (sharing, following)
4. Implement push notifications
5. Add beer scanning with camera
6. Create watchOS companion app
