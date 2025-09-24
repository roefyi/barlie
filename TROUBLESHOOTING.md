# Barlie iOS App - Troubleshooting Guide

## Common Issues and Solutions

### 1. Provisioning Profile Error
**Error:** `Build input file cannot be found: '/Users/Rome/Library/Developer/Xcode/UserData/Provisioning Profiles/[profile-id].mobileprovision'`

**Solution:**
This error occurs when Xcode is looking for a provisioning profile that doesn't exist. Here's how to fix it:

#### Option A: Use Automatic Code Signing (Recommended for Development)
1. Open `barlie.xcodeproj` in Xcode
2. Select the **barlie** project in the navigator
3. Select the **barlie** target
4. Go to **Signing & Capabilities** tab
5. Check **"Automatically manage signing"**
6. Select your **Team** (your Apple ID)
7. Change the **Bundle Identifier** to something unique like `com.yourname.barlie`

#### Option B: Manual Code Signing Fix
1. In Xcode, go to **Preferences** (⌘,)
2. Go to **Accounts** tab
3. Sign in with your Apple ID if not already signed in
4. Click **Download Manual Profiles**
5. Go back to project settings and select your team

#### Option C: Clean Build Folder
1. In Xcode, go to **Product** → **Clean Build Folder** (⇧⌘K)
2. Delete derived data: **Window** → **Organizer** → **Projects** → Delete Derived Data
3. Restart Xcode
4. Try building again

### 2. Bundle Identifier Conflicts
**Error:** `No profiles for 'com.yourcompany.barlie' were found`

**Solution:**
1. In Xcode project settings, change the Bundle Identifier
2. Use a unique identifier like: `com.yourname.barlie` or `com.yourcompany.barlie2024`

### 3. iOS Deployment Target Issues
**Error:** Various deployment target related errors

**Solution:**
1. Ensure iOS Deployment Target is set to 15.0 or higher
2. In project settings, check **Deployment Info** → **iOS Deployment Target**

### 4. Missing Files Error
**Error:** `No such file or directory` for Swift files

**Solution:**
1. Make sure all Swift files are added to the Xcode project
2. Check that files are in the correct target membership
3. Right-click files → **Add Files to "barlie"** if needed

## Step-by-Step Setup Guide

### 1. Initial Setup
```bash
# Navigate to your project directory
cd /Users/Rome/Desktop/Swift/iOSapps/barlie

# Run the setup script
./setup_ios_project.sh
```

### 2. Xcode Configuration
1. Open `barlie.xcodeproj` in Xcode
2. Select the project in navigator
3. Configure signing:
   - Go to **Signing & Capabilities**
   - Enable **"Automatically manage signing"**
   - Select your development team
   - Change Bundle Identifier to something unique

### 3. Build and Run
1. Select a simulator or device
2. Press **⌘R** to build and run
3. The app should launch with the dark theme and animations

## File Structure Verification

Make sure your project has this structure:
```
barlie/
├── barlie.xcodeproj/
│   └── project.pbxproj
├── barlie/
│   ├── BarlieApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   │   └── Beer.swift
│   ├── Views/
│   │   ├── DiscoverView.swift
│   │   ├── MyBarlieView.swift
│   │   └── BeerRatingView.swift
│   ├── ViewModels/
│   │   ├── DiscoverViewModel.swift
│   │   └── MyBarlieViewModel.swift
│   ├── Utilities/
│   │   ├── AnimationExtensions.swift
│   │   └── CustomTabBar.swift
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── Preview Content/
│       └── Preview Assets.xcassets
├── setup_ios_project.sh
└── TROUBLESHOOTING.md
```

## Testing the App

### Simulator Testing
1. Choose an iPhone simulator (iPhone 15 recommended)
2. Build and run (⌘R)
3. Test both tabs: Discover and My Barlie
4. Verify animations work smoothly
5. Test search functionality
6. Test tab switching

### Device Testing (Optional)
1. Connect your iPhone via USB
2. Trust the computer on your phone
3. Select your device in Xcode
4. You may need to enable Developer Mode on your device

## Advanced Configuration

### Adding Real Data
1. Replace sample data in `Beer.sampleBeers`
2. Add API integration in ViewModels
3. Implement Core Data for persistence

### Customization
1. Modify colors in SwiftUI views
2. Adjust animations in `AnimationExtensions.swift`
3. Update haptic feedback patterns
4. Customize the tab bar appearance

## Getting Help

If you're still having issues:
1. Check Xcode console for specific error messages
2. Verify all files are properly added to the project
3. Ensure you have the latest version of Xcode
4. Try creating a new Xcode project and copying files over

## Common Xcode Shortcuts
- **⌘R** - Build and Run
- **⌘B** - Build
- **⇧⌘K** - Clean Build Folder
- **⌘,** - Preferences
- **⌘0** - Show/Hide Navigator
- **⌘1** - Project Navigator
- **⌘2** - Source Control Navigator
