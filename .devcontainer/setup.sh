#!/bin/bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Pre-download dependencies
flutter doctor
flutter precache

