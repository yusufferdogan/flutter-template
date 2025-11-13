#!/bin/bash

# Generate freezed and json_serializable code
echo "Generating code with build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Code generation complete!"
