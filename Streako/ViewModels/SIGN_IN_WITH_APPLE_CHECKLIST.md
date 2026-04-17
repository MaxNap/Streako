# Sign in with Apple - Configuration Checklist

## ✅ Code Issues Fixed

1. **Updated `AuthService.swift`**
   - ✅ Changed from deprecated `OAuthProvider.appleCredential()` to modern `OAuthProvider(providerID:).credential()`
   - ✅ Added better error handling with specific error cases
   - ✅ Added display name update for new Apple Sign In users
   
2. **Updated `LoginView.swift`**
   - ✅ Improved error handling in Sign in with Apple button
   - ✅ Added guard statements to prevent nil credential issues
   - ✅ Filter out user cancellation errors (don't show error when user taps "Cancel")

3. **Updated `AuthViewModel.swift`**
   - ✅ Added Apple Sign In specific error handling
   - ✅ Added account conflict error messages

## 🔧 Xcode Project Configuration

### 1. Enable Sign in with Apple Capability
- [ ] Open your project in Xcode
- [ ] Select your target (Streako)
- [ ] Go to "Signing & Capabilities" tab
- [ ] Click "+ Capability" button
- [ ] Add "Sign in with Apple"

### 2. Verify Bundle Identifier
- [ ] Go to "Signing & Capabilities"
- [ ] Ensure your Bundle Identifier matches what's registered in Apple Developer

### 3. Verify Team Selection
- [ ] Ensure a valid development team is selected
- [ ] Make sure you have proper signing certificates

## 🔥 Firebase Console Configuration

### 1. Enable Apple Sign In Provider
- [ ] Go to [Firebase Console](https://console.firebase.google.com)
- [ ] Select your Streako project
- [ ] Navigate to "Authentication" → "Sign-in method"
- [ ] Find "Apple" in the list of providers
- [ ] Click "Enable"
- [ ] Click "Save"

### 2. (Optional) Add Service ID for Web/Other Platforms
- [ ] Only needed if you're also building for web or other platforms
- [ ] Create a Service ID in Apple Developer Portal
- [ ] Add it to Firebase Apple provider settings

## 🍎 Apple Developer Portal Configuration

### 1. App ID Configuration
- [ ] Go to [Apple Developer Portal](https://developer.apple.com/account)
- [ ] Navigate to "Certificates, Identifiers & Profiles"
- [ ] Select "Identifiers"
- [ ] Find your App ID (matching your bundle identifier)
- [ ] Ensure "Sign in with Apple" capability is checked
- [ ] If you made changes, click "Save"

### 2. Update Provisioning Profiles (if needed)
- [ ] If you enabled Sign in with Apple capability just now
- [ ] You may need to regenerate provisioning profiles
- [ ] Download and install the updated profiles in Xcode

## 📱 Testing Checklist

### Before Testing
- [ ] Clean build folder (Cmd + Shift + K)
- [ ] Delete app from simulator/device
- [ ] Rebuild and install fresh

### Testing Steps
1. [ ] Launch app on a real device (Sign in with Apple doesn't work well in Simulator)
2. [ ] Tap "Sign in with Apple" button
3. [ ] Verify Apple Sign In sheet appears
4. [ ] Complete sign in with your Apple ID
5. [ ] Verify you're successfully authenticated
6. [ ] Check that user data is stored correctly
7. [ ] Try signing out and signing in again
8. [ ] Test "Hide My Email" feature if needed

### Common Testing Issues

**Issue**: Button doesn't respond
- Solution: Make sure capability is enabled and app is rebuilt

**Issue**: "Invalid client" error
- Solution: Bundle identifier in Xcode must match App ID in Developer Portal

**Issue**: "Invalid token" error  
- Solution: Check that nonce is being generated and used correctly (✅ Fixed in code)

**Issue**: Works on one device but not another
- Solution: Sign out of Apple ID on device, sign back in, try again

**Issue**: Email is empty after sign in
- Solution: This is normal if user chose "Hide My Email" - Firebase will use the private relay email

## 🐛 Debugging Tips

### Enable Firebase Debug Logging
Add this to your AppDelegate:

```swift
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Enable Firebase debug logging
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
        FirebaseApp.configure()
        return true
    }
}
```

### Check Console Logs
Look for these patterns:
- `[AuthenticationServices]` - Apple Sign In specific logs
- `[FirebaseAuth]` - Firebase authentication logs
- Any error messages or stack traces

### Verify Firebase Configuration
- [ ] Ensure `GoogleService-Info.plist` is in your project
- [ ] Verify it's included in your target's "Copy Bundle Resources"
- [ ] Make sure it's the correct file for your Firebase project

## 📚 Additional Resources

- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Apple Sign In Guide](https://firebase.google.com/docs/auth/ios/apple)
- [AuthenticationServices Framework](https://developer.apple.com/documentation/authenticationservices)

## ✨ What Was Fixed in Your Code

### Main Issue
The code was using a **deprecated Firebase API** for Apple Sign In:
```swift
// ❌ OLD (Deprecated)
OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)

// ✅ NEW (Correct)
OAuthProvider(providerID: "apple.com").credential(withIDToken:rawNonce:)
```

### Other Improvements
1. Better error handling for user cancellations
2. Specific error messages for Apple Sign In failures
3. Display name update for new users
4. Guard statements to prevent nil credential crashes
5. Improved error mapping in AuthViewModel

---

**After completing this checklist, your Sign in with Apple should work!** 🎉

If you still have issues, check the debugging section and console logs.
