# Mac package builder & Notorization


![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20|%20Windows-blue)

## Introduction

**MultiCI** is a powerful installer framework designed for the Fatique Audio Plugin by Babelson Audio. It provides seamless packaging, signing, notarization, and integration for audio plugins across multiple formats, including **AU**, **VST3**, and **AAX**. MultiCI ensures compatibility with macOS and Windows.

## Features

- Support for multiple audio plugin formats:
  - **AU (Audio Unit)**
  - **VST3**
  - **AAX**
- Advanced signing and notarization process for macOS security compliance.
- Automatic stapling after notarization.
- Cross-platform support for **macOS** and **Windows**.
- Modular build system powered by **CMake**.
- TurboActivate Integration for license validation.
  
## Prerequisites

Before using or building MultiCI, ensure you have the following tools and dependencies installed:

- CMake (Version 3.24.1 or later)
- JUCE Framework (Includes DSP support)
- macOS Development:
  - Xcode and Command Line Tools
  - macOS SDK (Version 12.0 or later)
  - Deployment target: macOS 10.13 or later
- Windows Development:
  - Visual Studio 2022
- TurboActivate library for licensing

## Getting Started

Follow these steps to set up and build MultiCI on your development environment.

### 1. Clone the Repository
