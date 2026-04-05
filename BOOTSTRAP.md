# Bootstrap — Module 0

Flutter isn't installed on this machine. Once it is, run these steps in order.

## 1. Install Flutter
https://docs.flutter.dev/get-started/install/windows

Verify:
```bash
flutter --version
flutter doctor
```

## 2. Scaffold the platform folders
Run from `D:\OrangeDen\repos\message-parser`:

```bash
flutter create . \
  --org com.orangeden \
  --project-name message_parser \
  --platforms ios,android \
  --no-overwrite
```

The `--no-overwrite` flag keeps `pubspec.yaml`, `lib/main.dart`, and our POC sources intact.
Flutter will generate `android/`, `ios/`, `test/`, `.gitignore`, and the gradle wrappers.

## 3. Apply the Android permission patch
Open `android/app/src/main/AndroidManifest.xml` and add above `<application>`:

```xml
<uses-permission android:name="android.permission.READ_SMS"/>
```

See `android/app/src/main/AndroidManifest.xml.patch` for the full snippet.

## 4. Set minimum SDK versions
`another_telephony` needs Android minSdk 23+.
Edit `android/app/build.gradle` (or `build.gradle.kts`):

```gradle
defaultConfig {
    minSdkVersion 23
}
```

## 5. Install dependencies
```bash
flutter pub get
```

## 6. Run on device
```bash
# Android (physical device recommended — emulator inbox is empty)
flutter run

# iOS (simulator is fine for paste area)
flutter run -d ios
```

## 7. Acceptance check — Module 0
- [ ] Android: grants READ_SMS, shows sender list with real counts
- [ ] Android: tapping a sender opens the raw message list
- [ ] iOS: paste area splits messages by blank line and displays them
- [ ] No crash on permission denial — "Permission required" empty state shows

When all boxes are checked, Module 0 is done. Confirm before we move to Module 0.5.
