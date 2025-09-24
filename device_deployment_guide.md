# 📱 Barlie iOS App - Device Deployment Guide

## 🚨 Current Issues
- Bundle identifier is a placeholder (`com.yourcompany.barlie`)
- Development team ID is invalid (`S2RZZZ99HT`)
- Code signing certificates are revoked
- Need proper Apple Developer account setup

## ✅ Step-by-Step Solution

### Step 1: Fix Apple Developer Account
1. **Open Xcode**
2. **Go to Xcode → Settings (or Preferences)**
3. **Click "Accounts" tab**
4. **Add your Apple ID** (romansdenson@gmail.com) if not already added
5. **Select your Apple ID and click "Manage Certificates"**
6. **Click the "+" button and select "Apple Development"**
7. **Wait for the certificate to be created**

### Step 2: Fix Project Configuration
1. **In Xcode, open the project**: `barlie/barlie.xcodeproj`
2. **Select the "barlie" project** (blue icon) in navigator
3. **Select the "barlie" target** under TARGETS
4. **Go to "Signing & Capabilities" tab**
5. **Check "Automatically manage signing"**
6. **Select your Apple ID team** from the dropdown
7. **Change Bundle Identifier** to: `com.rome.barlie` (or any unique identifier)

### Step 3: Deploy to Device
1. **Connect your iPhone via USB**
2. **Trust the computer** on your iPhone when prompted
3. **In Xcode, select your iPhone** as the build target (top toolbar)
4. **Press ⌘+R** to build and run

### Step 4: Trust Developer on iPhone
If you get "Untrusted Developer" error:
1. **Go to Settings → General → VPN & Device Management**
2. **Find your Apple ID under "Developer App"**
3. **Tap it and select "Trust"**

## 🔧 Alternative: Command Line Fix

If you prefer command line, run these commands:

```bash
# 1. Open Xcode to fix certificates
open -a Xcode

# 2. After fixing certificates in Xcode, try building:
cd /Users/Rome/Desktop/Swift/iOSapps/barlie
xcodebuild build -project barlie/barlie.xcodeproj -scheme barlie -destination "platform=iOS,id=00008110-000A0D3E3AEA401E" -allowProvisioningUpdates
```

## 📋 Your Connected Devices
- iPhone (18.7) - ID: 00008110-000A0D3E3AEA401E
- iPhone (5) - ID: 00008110-000A20D91EE8401E

## 🎯 Expected Result
After following these steps, the app should build and install on your iPhone successfully!

## 🆘 If Still Having Issues
1. Make sure you have a valid Apple Developer account
2. Check that your iPhone is unlocked and trusted
3. Try restarting Xcode and your iPhone
4. Check Xcode → Window → Devices and Simulators to verify device connection
