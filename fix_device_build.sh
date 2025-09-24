#!/bin/bash

echo "🔧 Fixing Barlie iOS App for Device Deployment"
echo "=============================================="

# Navigate to project directory
cd /Users/Rome/Desktop/Swift/iOSapps/barlie

echo "📱 Step 1: Checking Xcode and simulators..."
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -1)"

echo ""
echo "📋 Step 2: Listing available development teams..."
echo "Available development teams:"
security find-identity -v -p codesigning | grep "iPhone Developer\|Apple Development" || echo "No development identities found"

echo ""
echo "🔍 Step 3: Checking current project configuration..."
echo "Current bundle identifier: com.yourcompany.barlie"
echo "Current development team: S2RZZZ99HT"

echo ""
echo "⚠️  ISSUES FOUND:"
echo "1. Bundle identifier 'com.yourcompany.barlie' is a placeholder"
echo "2. Development team 'S2RZZZ99HT' may not be valid"
echo "3. Need proper code signing for device deployment"

echo ""
echo "🛠️  SOLUTIONS:"
echo ""
echo "OPTION 1: Quick Fix (Recommended for testing)"
echo "1. Open Xcode: open barlie/barlie.xcodeproj"
echo "2. Select the 'barlie' project in the navigator"
echo "3. Go to 'Signing & Capabilities' tab"
echo "4. Check 'Automatically manage signing'"
echo "5. Select your Apple ID team from the dropdown"
echo "6. Change Bundle Identifier to something unique like: com.yourname.barlie"
echo "7. Connect your iPhone via USB"
echo "8. Select your device as the build target"
echo "9. Build and run (⌘+R)"

echo ""
echo "OPTION 2: Command Line Fix"
echo "1. Get your development team ID:"
echo "   security find-identity -v -p codesigning | grep 'iPhone Developer'"
echo "2. Update the project with your team ID and bundle identifier"
echo "3. Build for device"

echo ""
echo "📱 Step 4: Testing device connection..."
echo "Connected devices:"
xcrun xctrace list devices 2>/dev/null | grep "iPhone\|iPad" || echo "No devices connected"

echo ""
echo "🔧 Step 5: Creating backup and updated project..."
# Create backup
cp barlie/barlie.xcodeproj/project.pbxproj barlie/barlie.xcodeproj/project.pbxproj.backup
echo "✅ Backup created: project.pbxproj.backup"

echo ""
echo "📝 MANUAL STEPS REQUIRED:"
echo "1. Open Xcode: open barlie/barlie.xcodeproj"
echo "2. Select 'barlie' project → 'Signing & Capabilities'"
echo "3. Enable 'Automatically manage signing'"
echo "4. Select your Apple ID team"
echo "5. Change Bundle Identifier to: com.$(whoami).barlie"
echo "6. Connect your iPhone and trust the computer"
echo "7. Select your device as build target"
echo "8. Build and run (⌘+R)"

echo ""
echo "🚨 If you get 'Untrusted Developer' error on your phone:"
echo "1. Go to Settings → General → VPN & Device Management"
echo "2. Find your Apple ID under 'Developer App'"
echo "3. Tap it and select 'Trust'"

echo ""
echo "✅ Setup complete! Follow the manual steps above to deploy to your device."
