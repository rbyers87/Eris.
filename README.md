# Eris Android 🪐

<div align="center">
  <img src="app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="128" height="128" alt="Eris Icon">
  
  **Chat with AI privately on your Android device**
  
  [![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://developer.android.com/studio/)
  [![Kotlin](https://img.shields.io/badge/Kotlin-1.9+-purple.svg)](https://kotlinlang.org/)
  [![Compose](https://img.shields.io/badge/Jetpack%20Compose-1.5+-blue.svg)](https://developer.android.com/jetpack/compose)
</div>

## About

Eris Android is a private AI chat application that runs entirely on your device. This is the Android equivalent of the iOS Eris app, built with modern Android technologies including Jetpack Compose, Room, and TensorFlow Lite.

### Key Features

- 🔒 **100% Private** - All conversations stay on your device
- 🚀 **Fast Performance** - Optimized for Android devices
- 📡 **Offline First** - Works without internet connection after setup
- 🤖 **Multiple Models** - Support for various quantized AI models
- 🎨 **Material Design** - Beautiful, native Android UI
- 💾 **Local Storage** - Your data never leaves your device
- 📝 **Markdown Support** - Rich text formatting in conversations
- 🌙 **Dark/Light Theme** - Adaptive theming support

## Requirements

### For Users
- Android 8.0 (API level 26) or higher
- 4GB+ RAM recommended
- 2-8GB free storage per model
- ARM64 processor recommended for best performance

### For Developers
- Android Studio Hedgehog (2023.1.1) or newer
- JDK 8 or higher
- Android SDK 34
- Gradle 8.2+

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/Natxo09/Eris-Android.git
cd Eris-Android
```

2. Open in Android Studio:
- Open Android Studio
- Select "Open an existing project"
- Navigate to the cloned directory

3. Build and run:
- Connect your Android device or start an emulator
- Click "Run" or press Ctrl+R (Cmd+R on Mac)

## Architecture

This app follows modern Android development best practices:

### Tech Stack
- **UI**: Jetpack Compose with Material 3
- **Architecture**: MVVM with Repository pattern
- **Database**: Room for local data persistence
- **DI**: Hilt for dependency injection
- **ML**: TensorFlow Lite and ONNX Runtime for AI models
- **Navigation**: Navigation Compose
- **Async**: Kotlin Coroutines and Flow

### Project Structure
```
app/src/main/java/dev/natxo/eris/
├── data/
│   ├── database/         # Room database, DAOs, entities
│   ├── models/           # Data models
│   ├── repository/       # Repository implementations
│   └── preferences/      # DataStore preferences
├── ml/                   # Machine learning components
├── ui/
│   ├── screens/          # Compose screens
│   ├── viewmodels/       # ViewModels
│   ├── navigation/       # Navigation setup
│   └── theme/            # Material theming
└── di/                   # Hilt modules
```

## Supported Models

The Android version supports quantized models optimized for mobile devices:

### General Purpose
- **Llama 3.2** (1B) - Meta's efficient model
- **Qwen 2.5** (0.5B, 1.5B) - Alibaba's multilingual models

### Reasoning
- **DeepSeek-R1-Distill-Qwen** (1.5B) - Advanced reasoning capabilities

*Note: Model support is currently simulated. Real model integration requires implementing TensorFlow Lite or ONNX Runtime inference.*

## Key Differences from iOS Version

### Technology Adaptations
- **MLX → TensorFlow Lite/ONNX**: Android uses TensorFlow Lite and ONNX Runtime instead of Apple's MLX
- **SwiftUI → Jetpack Compose**: Modern declarative UI framework for Android
- **SwiftData → Room**: Type-safe database library for Android
- **UserDefaults → DataStore**: Modern preferences storage

### Android-Specific Features
- **Material Design 3**: Native Android design language
- **Dynamic Color**: Adapts to system wallpaper colors (Android 12+)
- **Predictive Back**: Smooth navigation animations
- **Edge-to-Edge**: Modern full-screen experience

## Development Status

This is a functional Android port with the following implementation status:

✅ **Completed**:
- Complete UI implementation with Jetpack Compose
- Database layer with Room
- Navigation and state management
- Settings and preferences
- Onboarding flow
- Model management UI

🚧 **In Progress**:
- Real AI model integration (currently simulated)
- Model downloading and caching
- Advanced markdown rendering
- Performance optimizations

📋 **Planned**:
- Voice input support
- Export/import conversations
- Widget support
- Shortcuts integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Privacy & Security

- ✅ No telemetry or analytics
- ✅ No network requests except for model downloads
- ✅ All data stored locally using Room
- ✅ Models cached locally after download
- ✅ Full data deletion available in settings

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the iOS Eris app
- Built with modern Android development practices
- Uses open-source libraries and frameworks

## Developer

Created by Ignacio Palacio - [natxo.dev](https://natxo.dev)

---

*This Android port maintains the privacy-first philosophy of the original iOS app while leveraging the best of Android's ecosystem.*