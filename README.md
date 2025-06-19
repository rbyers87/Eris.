# Eris. 🪐

<div align="center">
  <img src="Eris./Assets.xcassets/AppIconNoBg.imageset/ChatGPT Image 19 jun 2025, 09_16_02.png" width="128" height="128" alt="Eris Icon">
  
  **Chat with AI privately on your iPhone and iPad**
  
  [![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS-blue.svg)](https://developer.apple.com/xcode/)
  [![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
  [![MLX](https://img.shields.io/badge/MLX-Apple%20Silicon-green.svg)](https://github.com/ml-explore/mlx)
</div>

## About

Eris is a private AI chat application that runs entirely on your device using Apple's MLX framework. Named after the dwarf planet that challenged our understanding of the solar system, Eris challenges the notion that AI must live in the cloud.

### Key Features

- 🔒 **100% Private** - All conversations stay on your device
- 🚀 **Blazing Fast** - Powered by Apple Silicon and MLX
- 📡 **Offline First** - Works without internet connection
- 🤖 **Multiple Models** - Support for Llama, Qwen, DeepSeek, and more
- 🎨 **Native Design** - Built with SwiftUI for a seamless Apple experience
- 💾 **Local Storage** - Your data never leaves your device
- 🎯 **Syntax Highlighting** - Beautiful code blocks with syntax highlighting for 100+ languages
- 📝 **Markdown Support** - Full markdown rendering for formatted text, lists, tables, and more
- 🌑 **Dark Mode** - Easy on your eyes, day or night
- ☀️ **Light Mode** - Clean and bright interface for daytime use

## Requirements

### For Users
- iPhone with A12 Bionic chip or newer (iPhone XS/XR and later)
- iPad with A12 Bionic chip or newer
- iOS 17.6+ / iPadOS 17.6+
- ~2-8GB free storage per model

### For Developers
- Apple Silicon Mac (M1, M2, M3, M4)
- macOS 14.0+
- Xcode 15.0+
- Physical iPhone/iPad for testing (see note below)

⚠️ **Important Development Note**: iOS Simulators are not supported as MLX requires actual hardware acceleration. You'll need a physical iPhone or iPad with A12 chip or newer for testing and debugging.

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/Natxo09/Eris.git
cd Eris.
```

2. Open in Xcode:
```bash
open Eris..xcodeproj
```

3. Select your target device and build (⌘+B)

4. Run the app (⌘+R)

## Supported Models

Eris supports a variety of quantized models optimized for Apple Silicon:

### General Purpose
- **Llama 3.2** (1B, 3B) - Meta's latest efficient models
- **Qwen 2.5** (0.5B, 1.5B, 3B) - Alibaba's multilingual models
- **Mistral 7B** - Popular open-source model
- **Gemma 2** (2B) - Google's lightweight model
- **Phi 3.5 Mini** - Microsoft's small but capable model

### Reasoning
- **DeepSeek-R1-Distill-Qwen** (1.5B in 4bit/8bit) - Advanced reasoning capabilities

### Code
- **CodeLlama 7B** - Specialized for programming tasks
- **StableCode 3B** - Efficient code generation

## Usage

1. **First Launch**: The app will guide you through downloading your first model
2. **Chat**: Start conversations with your AI assistant
3. **Switch Models**: Access different models from Settings → Model Management
4. **Manage Data**: Delete chats or models from Settings → Danger Zone

## Privacy & Security

- ✅ No telemetry or analytics
- ✅ No network requests except for model downloads
- ✅ All data stored locally using SwiftData
- ✅ Models downloaded from Hugging Face are cached locally
- ✅ Full data deletion available in settings

## Technical Details

### Architecture
- **UI**: SwiftUI
- **ML Framework**: MLX / MLX Swift
- **Data Persistence**: SwiftData
- **Model Format**: Quantized models (4-bit/8-bit)

### Project Structure
```
Eris./
├── Models/          # Data models and ML integration
├── Views/           # SwiftUI views
│   ├── Chat/        # Chat interface
│   ├── Settings/    # Settings and management
│   └── Onboarding/  # First-run experience
└── Utils/           # Utilities and helpers
```

## Roadmap

View our roadmap and progress at [eris.natxo.dev/roadmap](https://eris.natxo.dev/roadmap)

### Bug Fixes
- [x] Chat name only applies after exiting and re-entering the chat
- [ ] Improve Markdown formatting for AI responses

### Upcoming Features
- [ ] Voice input/dictation support (OpenAI Whisper or similar)
- [ ] Image support in conversations
- [ ] Native macOS app (not iPad port)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

This project was inspired by [Fullmoon iOS](https://github.com/mainframecomputer/fullmoon-ios) and wouldn't be possible without:

- Apple's [MLX](https://github.com/ml-explore/mlx) framework
- The [Hugging Face](https://huggingface.co) community
- All the open-source model creators

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Developer

Created by Ignacio Palacio - [natxo.dev](https://natxo.dev)

---

### A Note About the Commit History 😴

If you're browsing through the commit history and wondering why there are so many commits that just say "commit"... well, I have a confession to make. 

I started this project late one night with zero intention of it becoming anything serious. It was supposed to be a quick experiment, maybe a few lines of code to test out MLX. But you know how it goes - "just one more feature" turned into "oh, this actually works!" which turned into "wait, people might actually use this."

So there I was, half-asleep, committing code with the eloquence of a zombie: "commit", "commit", "commit". By the time I realized this was becoming a real project, the damage was done. My git history looks like I fell asleep on the keyboard with my finger on the enter key.

I promise I'm usually better at commit messages. Usually. When I'm awake. ☕

*PS: If you're a hiring manager reading this, I swear this isn't representative of my professional work. Please check out my other repos where I actually wrote meaningful commit messages like "fix: resolved null pointer exception in user authentication flow" instead of just "commit" 47 times in a row.*