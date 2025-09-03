# 🛠️ ResQAlerts Setup Instructions

## Prerequisites
- **Flutter SDK** 3.7.0 or higher
- **Android Studio** with Flutter plugin
- **Firebase Account** (free)
- **Google Cloud Console Account** (free tier available)
- **Physical Android device** or emulator for testing

## 🔥 Firebase Configuration

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Enter project name (e.g., "resqalerts-yourname")
4. **Disable Google Analytics** (optional for this project)
5. Click **"Create project"**

### Step 2: Configure Firebase Services

#### 2.1 Authentication Setup
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **"Email/Password"** sign-in provider
3. Click **Save**

#### 2.2 Firestore Database Setup
1. Go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"** 
4. Select your preferred region
5. Click **Done**

#### 2.3 Storage Setup
1. Go to **Storage**
2. Click **"Get started"**
3. Keep default security rules for now
4. Choose same region as Firestore
5. Click **Done**

#### 2.4 Cloud Messaging Setup
1. Go to **Cloud Messaging**
2. No additional configuration needed - it's auto-enabled

### Step 3: Add Android App to Firebase
1. In Firebase Console, click **"Add app"** > **Android icon**
2. **Android package name:** `com.example.resqalerts`
3. **App nickname:** `ResQAlerts` (optional)
4. **Debug signing certificate SHA-1:** Leave blank for now
5. Click **"Register app"**

### Step 4: Download and Configure Firebase
1. **Download** the `google-services.json` file
2. **Copy** the template file:
   ```bash
   cp android/app/google-services.json.template android/app/google-services.json
   ```
3. **Replace** the template values with your actual Firebase data:
   - Open the downloaded `google-services.json` from Firebase
   - Copy values and replace placeholders in your local file:
     - `YOUR_PROJECT_NUMBER` → your project number
     - `YOUR_PROJECT_ID` → your project ID  
     - `YOUR_MOBILE_SDK_APP_ID` → your mobile SDK app ID
     - `YOUR_FIREBASE_API_KEY` → your API key

## 🗺️ Google Maps Setup

### Step 1: Enable Google Cloud APIs
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. **Select your Firebase project** (or create new one)
3. **Enable billing** (required for Maps API - free tier includes generous limits)

### Step 2: Enable Required APIs
1. Go to **APIs & Services** > **Library**
2. Search and enable these APIs:
   - **Maps SDK for Android**
   - **Places API** (optional - for location search features)

### Step 3: Create and Configure API Key
1. Go to **APIs & Services** > **Credentials**
2. Click **"Create Credentials"** > **"API Key"**
3. Copy the API key
4. Click **"Restrict Key"** for security:
   - **Application restrictions:** Android apps
   - **Add package name:** `com.example.resqalerts`
   - **API restrictions:** Select "Maps SDK for Android"
5. Click **Save**

### Step 4: Add API Key to App
1. Open `android/app/src/main/AndroidManifest.xml`
2. Find this line:
   ```xml
   android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"
   ```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

## 📱 Installation and Setup

### Step 1: Clone and Install Dependencies
```bash
# Clone the repository
git clone https://github.com/your-username/resqalerts.git
cd resqalerts

# Install Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

### Step 2: Configure Local Files
```bash
# Copy Firebase template and configure (as done in Step 4 above)
cp android/app/google-services.json.template android/app/google-services.json

# Edit google-services.json with your Firebase project details
# Edit AndroidManifest.xml with your Google Maps API key
```

### Step 3: Build and Run
```bash
# Clean any previous builds
flutter clean
flutter pub get

# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# For release build (optional)
flutter build apk --release
```

## 🔒 Security Configuration

### Firestore Security Rules
After testing your app, update Firestore security rules:

1. Go to **Firestore Database** > **Rules**
2. Replace default rules with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Accidents can be read by authenticated users
    match /accidents/{accidentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Storage Security Rules
1. Go to **Storage** > **Rules**
2. Update rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /accident_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 🧪 Testing Your Setup

### Verify Firebase Connection
1. Run the app
2. Try creating an account with email/password
3. Check Firebase Console > Authentication > Users

### Verify Google Maps
1. Navigate to map screen in app
2. Check if map loads correctly
3. Verify location permissions work

### Test Notifications (Optional)
1. Go to Firebase Console > Cloud Messaging
2. Send a test message to your app
3. Verify notification is received

## 🔧 Troubleshooting

### Common Issues

#### Firebase Connection Problems
```bash
# Error: google-services.json not found
# Solution: Ensure file is in android/app/ directory

# Error: Package name mismatch
# Solution: Verify package name in Firebase matches build.gradle
```

#### Google Maps Issues
```bash
# Error: Map not loading
# Solutions:
# 1. Check API key is correct
# 2. Verify billing is enabled
# 3. Check API restrictions
# 4. Enable "Maps SDK for Android" API
```

#### Build Errors
```bash
# Clear build cache
flutter clean
flutter pub get

# Check Flutter setup
flutter doctor

# Verify Android dependencies
cd android && ./gradlew dependencies
```

#### Permission Issues
```bash
# Add to android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Getting Debug Information
```bash
# Run with verbose logging
flutter run --verbose

# Check Android logs
adb logcat | grep flutter

# Check Firebase debug logs in Android Studio
```

## 📦 Building for Production

### Generate Signed APK
1. **Create keystore** (one-time setup):
   ```bash
   keytool -genkey -v -keystore android/app/resqalerts-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias resqalerts
   ```

2. **Create key.properties**:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=resqalerts
   storeFile=resqalerts-release-key.jks
   ```

3. **Build release APK**:
   ```bash
   flutter build apk --release
   ```

### For Google Play Store
1. **Add SHA-1 fingerprint** to Firebase:
   ```bash
   keytool -list -v -keystore android/app/resqalerts-release-key.jks -alias resqalerts
   ```
2. Add the SHA-1 to Firebase project settings
3. Build App Bundle:
   ```bash
   flutter build appbundle --release
   ```

## 📞 Support and Resources

### Official Documentation
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Firebase Console](https://console.firebase.google.com)

### Common Resources
- [Flutter Doctor Issues](https://flutter.dev/docs/get-started/install)
- [Firebase Billing](https://firebase.google.com/pricing)
- [Google Cloud Free Tier](https://cloud.google.com/free)

### Getting Help
1. **Check existing issues** in this repository
2. **Run `flutter doctor`** to check your environment
3. **Check Firebase Console** for error logs
4. **Create an issue** with:
   - Error message
   - Steps to reproduce
   - Your environment (OS, Flutter version, etc.)

---

## ⚠️ Important Security Notes

- **Never commit** `google-services.json` to version control
- **Never share** your API keys publicly
- **Use restricted API keys** for production
- **Keep your keystore file** secure and backed up
- **Enable Firestore security rules** before going live

---

**📱 Ready to build? Follow these steps and you'll have ResQAlerts running in no time!**
