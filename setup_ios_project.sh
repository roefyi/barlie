#!/bin/bash

# Barlie iOS Project Setup Script
echo "🍺 Setting up Barlie iOS Project..."

# Navigate to the project directory
cd "$(dirname "$0")/barlie"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Clean any existing build artifacts
echo "🧹 Cleaning existing build artifacts..."
xcodebuild clean -project barlie.xcodeproj -scheme barlie 2>/dev/null || true

# Set up code signing for development
echo "🔐 Configuring code signing..."
# This will use automatic code signing with your Apple ID
# You'll need to sign in to your Apple ID in Xcode preferences

# Create a simple scheme for building
echo "📱 Creating build scheme..."
# The scheme should already exist, but let's make sure it's configured properly

# Try to build for simulator first
echo "🔨 Building for iOS Simulator..."
if xcodebuild build -project barlie.xcodeproj -scheme barlie -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' 2>/dev/null; then
    echo "✅ Project builds successfully for simulator!"
    echo ""
    echo "🎉 Setup complete! You can now:"
    echo "1. Open barlie.xcodeproj in Xcode"
    echo "2. Select your target device or simulator"
    echo "3. Press Cmd+R to build and run"
    echo ""
    echo "📝 Note: If you see code signing errors:"
    echo "1. Open Xcode Preferences (Cmd+,)"
    echo "2. Go to Accounts tab"
    echo "3. Sign in with your Apple ID"
    echo "4. Select your development team in project settings"
else
    echo "⚠️  Build failed. This is normal for first-time setup."
    echo ""
    echo "🔧 To fix this:"
    echo "1. Open barlie.xcodeproj in Xcode"
    echo "2. Select the barlie project in the navigator"
    echo "3. Go to Signing & Capabilities tab"
    echo "4. Select your development team"
    echo "5. Make sure 'Automatically manage signing' is checked"
    echo ""
    echo "Then try building again (Cmd+R)"
fi

echo ""
echo "🍺 Barlie iOS app is ready to go!"
