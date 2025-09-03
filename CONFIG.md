# 🔧 Configuration Files Guide

## 📁 File Structure
```
resqalerts/
├── android/app/
│   ├── google-services.json.template  ✅ Safe template (included in repo)
│   └── google-services.json           🚫 Real config (gitignored)
├── .gitignore                        ✅ Protects sensitive files
├── SETUP.md                          ✅ Complete setup guide
└── CONFIG.md                         ✅ This file
```

## 🔑 Required Configuration Files

### 1. Firebase Configuration
**File:** `android/app/google-services.json`
**Status:** 🚫 **NEVER COMMIT** (contains sensitive Firebase keys)
**How to get:** Download from Firebase Console after creating your project

### 2. Google Maps API Key  
**File:** `android/app/src/main/AndroidManifest.xml`
**Location:** Inside `<meta-data>` tag
**Status:** ⚠️ **REPLACE PLACEHOLDER** with your real API key

### 3. Signing Key (for production)
**File:** `android/app/resqalerts-release-key.jks`
**Status:** 🚫 **NEVER COMMIT** (used for app signing)
**How to create:** See SETUP.md instructions

## 🚨 Security Checklist

Before uploading to GitHub:
- [ ] ✅ `.gitignore` includes `google-services.json`
- [ ] ✅ Real API keys replaced with placeholders
- [ ] ✅ No `.jks` or `.keystore` files committed
- [ ] ✅ Template files created for guidance
- [ ] ✅ Setup instructions provided

## 🛠️ Quick Setup Commands

```bash
# 1. Copy template to create your config file
cp android/app/google-services.json.template android/app/google-services.json

# 2. Edit the file with your Firebase project data
# Replace all "YOUR_*" placeholders with actual values

# 3. Add your Google Maps API key to AndroidManifest.xml
# Replace "YOUR_GOOGLE_MAPS_API_KEY_HERE" with your key

# 4. Test the app
flutter clean && flutter pub get && flutter run
```

## 📞 Need Help?

- 📖 **Full Setup Guide:** See `SETUP.md`
- 🔧 **Troubleshooting:** Check SETUP.md troubleshooting section
- 🐛 **Issues:** Create GitHub issue with error details

---
**⚠️ Remember: Configuration files contain sensitive data - keep them secure!**
