# 🌟 Asma'ul Husna (99 Names of Allah)

<div align="center">
  <img src="assets/images/logo.png" alt="App Logo" width="120" style="border-radius: 20px;"/>
  <br/>
  
  **A beautiful, premium, and interactive mobile application to discover, learn, and memorize the 99 Beautiful Names of Allah.**
  
  ![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
  ![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
  ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)
  ![License](https://img.shields.io/badge/License-MIT-green)
</div>

---

## ✨ Features

- 📖 **Discover & Read:** Browse through all 99 Names of Allah with beautiful UI.
- 🇪🇹 **Bilingual Support (English & Amharic):** Seamless dynamic language switching for interpretations, audio selection, and standard UI elements.
- 🎧 **High-Quality Audio:** Listen to clear, professional pronunciations of each name. Includes a seamless "Play All" background audio marathon mode.
- 🧩 **Memorization Puzzle Game:** Interactive drag-and-drop levels to help you memorize the sequential order of the 99 names.
- 🧠 **Smart Practice Quiz:** A beautifully designed multiple-choice test system to evaluate your meaning and translation knowledge.
- 📿 **Digital Tasbih:** A sleek, fully-functional counting Tasbih with haptic feedback, cycle tracking, and goal management.
- 🌙 **Dark & Light Themes:** Premium aesthetics adapted automatically or manually to your environment's preference.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Channel Stable)
- **Language:** Dart
- **State Management:** Provider
- **Local Storage:** Shared Preferences

---

## 📸 Screenshots

*(To be added)*

---

## 🚀 Getting Started

### Prerequisites
Make sure you have installed the following:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 
- [Android Studio](https://developer.android.com/studio) or VS Code
- A running Android/iOS Emulator or a physical device connected.

### Installation & Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/allah_99_names.git
   cd allah_99_names
   ```

2. **Fetch Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run in Debug Mode**
   ```bash
   flutter run
   ```

### ⚡ Building for Production (Recommended)

To experience the maximum fluid animations without debugging lag:

**Generate a Split APK (Recommended for sideloading):**
```bash
flutter build apk --split-per-abi --release
```
APKs will be located at `build/app/outputs/flutter-apk/`.

**Generate an AppBundle (For Google Play Console):**
```bash
flutter build appbundle --release
```
The AAB file will be located at `build/app/outputs/bundle/release/app-release.aab`.

---

## 📁 Directory Structure

```text
lib/
 ┣ constants/         # App Colors, Styles, Constants, Localized Strings
 ┣ models/            # Data models (AllahName, Question, etc.)
 ┣ providers/         # State Management (Theme, Language, Audio, Names)
 ┣ screens/           # UI Screens (Home, Details, Tasbih, Puzzle, Practice)
 ┣ services/          # Abstract services (e.g., Notification)
 ┣ utils/             # Helper utilities, animations, custom routing
 ┗ main.dart          # Entry point of the application
assets/
 ┣ audio/             # Arabic audio pronunciations
 ┣ data/              # names.json (Core definition data source)
 ┗ images/            # App branding imagery
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome! 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---
<div align="center">
Made with ❤️ using Flutter.
</div>
