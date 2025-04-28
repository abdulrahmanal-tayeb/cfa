# CFA - Create Flutter App

> Created with ❤️ by **AmtCode**

---

## About

**CFA (Create Flutter App)** is a command-line tool designed to make your Flutter app creation experience much smoother and cleaner. Think of it as your personal assistant that actually knows how to deal with:

- Gradle compatibility (no more "which version do I need?" nightmares).
- NDK version mismatches.
- Gradle build folders taking up precious gigabytes unnecessarily.
- App name, package ID, bundle ID setup.
- Automatic configuration of Gradle, JDK, NDK settings.

All this happens through a simple and interactive CLI workflow, so you can skip the boring setup phase and jump right into coding your next big thing.

**Note:** This script is built for UNIX-based systems (Linux, macOS). Windows users may need to adapt or use WSL.

## Why CFA?

When you create a Flutter app normally, Flutter assumes you want its default environment, which might not match your system setup. That often leads to annoying compatibility issues, forced reconfiguration, and wasted disk space.

**CFA**:
- Prompts you for the correct Gradle, NDK, and JDK versions.
- Prevents re-downloading or reconfiguring environments unnecessarily.
- Helps you keep your projects neat, lean, and ready for action.

Because "It works on my machine" should be about your app, not your Flutter tooling. 😉

## Features

- 🔹 Choose the correct Gradle, NDK, and JDK versions easily.
- 🔹 Automatically rename your Flutter app and update the bundle ID.
- 🔹 Configure Android project files to match your setup without hassle.
- 🔹 Prevent bloated builds and unnecessary downloads.
- 🔹 Focus on building apps, not battling configurations.

## Installation

To make `cfa` globally available from anywhere in your terminal:

```bash
# 1. Move the script somewhere in your PATH, for example:
sudo mv cfa.sh /usr/local/bin/cfa

# 2. Make sure it’s executable:
sudo chmod +x /usr/local/bin/cfa

# 3. Now you can run it from anywhere:
cfa
```

> **Pro Tip:** You can also rename it to `cfa` when moving it, for an even smoother experience.

## Usage

```bash
cfa
```

The script will guide you step-by-step to:
- Set the application name
- Set the package/bundle ID
- Select your Gradle, JDK, and NDK versions
- Configure your project accordingly

Minimal thinking required. 💡

> **Important:**
> Make sure you have the required Flutter and SDK tools installed on your machine.

## Requirements

- Flutter installed ([installation guide](https://docs.flutter.dev/get-started/install))
- bash/zsh compatible terminal
- UNIX-based OS (Linux or macOS)
- Basic knowledge of your environment versions (Gradle, JDK, NDK)

## Contributions

Contributions are welcome! 🎉

Feel free to fork the repository, make your changes, and submit a pull request.

If you have suggestions or ideas, you can also reach out directly to **AmtCode**. 

Let's make Flutter app creation even better together!

## License

This project is licensed under the [MIT License](LICENSE).

---

Made with just a pinch of shell magic ✨ by **AmtCode**.

