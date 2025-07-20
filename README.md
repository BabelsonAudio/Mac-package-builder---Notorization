# Mac package builder & Notorization


![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20|%20Windows-blue)

## Introduction
**Mac-package-builder—Notarization** is a shell-based tool designed to streamline the creation, signing, and notarization of macOS packages for the **Fatique Audio Plugin** by Babelson Audio. It simplifies the packaging process for audio plugins in multiple formats, ensuring compliance with modern macOS and Windows security and distribution requirements.

## Features

- **Multi-format support**:
  - **AU (Audio Unit)**
  - **VST3**
  - **AAX**
- **macOS Notarization**:
  - Advanced signing and notarization process compliant with macOS security policies.
  - Automatic stapling of notarization tickets.
- **Shell Script-Based Workflow**:
  - Flexible, portable, lightweight approach.
  - No reliance on external frameworks beyond required tools.
- **Cross-platform Compatibility**:
  - Support for macOS and Windows packaging workflows.
- **Modular Configuration**:
  - Portable implementation with dependencies defined in `CMakeLists.txt`.

  
## Prerequisites

Before using this project, ensure the following tools and dependencies are installed:

### macOS Requirements
- **CMake** (Version 3.24.1 or later).
- **Xcode** and Command Line Tools.
- **macOS SDK**:
  - Version 12.0 or later.
  - Deployment target set to macOS 10.13 or higher.
- **Code Signing and Notarization** tools:
  - Developer ID application and team configured in `CMakeLists.txt`.

### Windows Requirements
- Visual Studio 2022 or higher.

### Optional
- External audio libraries and toolchains (e.g., **JUCE**, **TurboActivate**, **DSP Filters**) integrated via `CMakeLists.txt`.


## Getting Started

Follow these steps to set up and build Mac-package-builder--->Notorization on your development environment.

### 1. Clone the Repository
and use always cd/.....


### 2. Set Up Submodules

Ensure all necessary submodules are initialized and updated.


### 3. Install Prerequisites

- MacOS:
  ```bash
  brew install cmake
  ```

- Windows:
  Download and install Visual Studio (2022 or later) and TurboActivate libraries.

### 4. Build the Project

#### macOS:

#### Windows:
- Open the project in Visual Studio and build the `Release` configuration.

### 5. Create the Installer

Run the script to generate the installer for the Fatique plugin:


### 6. Run Tests (Optional)


---

## Project Structure

**Key Directories**


---

## Contributing

We welcome contributions from the community! Please follow these guidelines to help us maintain a high-quality project:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/my-feature-name`.
3. Make your changes and test thoroughly.
4. Submit a pull request describing the proposed changes.

---

## Support and Contact

For inquiries or support, reach out to:

- **Author:** Thomas Ceyhan, Babelson Audio
- **Email:** [support@cynicos.com](mailto:support@cynicos.com)
- **Website:** [www.cynicos.com](https://www.cynicos.com)

---

## License

This project and all associated code fall under a **confidential license**. All rights are reserved by **Babelson Audio**, 2025.

---
