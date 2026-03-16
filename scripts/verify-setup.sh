#!/bin/bash

# AVC Flutter Setup Verification Script
# This script verifies that the build environment is properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Verifying AVC Flutter build setup..."

# Change to Flutter project directory
cd "$(dirname "$0")/.."

# Check Flutter installation
print_status "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    flutter --version
    print_success "Flutter is installed"
else
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter doctor
print_status "Running Flutter doctor..."
flutter doctor

# Check dependencies
print_status "Checking dependencies..."
flutter pub get

# Check code generation
print_status "Checking code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check code analysis
print_status "Running code analysis..."
flutter analyze

# Check formatting
print_status "Checking code formatting..."
dart format --set-exit-if-changed . || print_warning "Code formatting issues found"

# Check tests
print_status "Running tests..."
flutter test

# Check Android configuration
print_status "Checking Android configuration..."
if [[ -f "android/app/build.gradle" ]]; then
    print_success "Android build.gradle found"
else
    print_error "Android build.gradle not found"
fi

if [[ -f "android/key.properties" ]]; then
    print_success "Android signing configuration found"
else
    print_warning "Android signing configuration not found (required for release builds)"
fi

# Check iOS configuration (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Checking iOS configuration..."
    if [[ -f "ios/Runner/Info.plist" ]]; then
        print_success "iOS Info.plist found"
    else
        print_error "iOS Info.plist not found"
    fi
    
    if [[ -f "ios/ExportOptions.plist" ]]; then
        print_success "iOS ExportOptions.plist found"
    else
        print_warning "iOS ExportOptions.plist not found (required for distribution)"
    fi
else
    print_warning "iOS configuration check skipped (not on macOS)"
fi

# Check Firebase configuration
print_status "Checking Firebase configuration..."
if [[ -f "android/app/google-services.json" ]]; then
    print_success "Android Firebase configuration found"
else
    print_warning "Android Firebase configuration not found"
fi

if [[ -f "ios/Runner/GoogleService-Info.plist" ]]; then
    print_success "iOS Firebase configuration found"
else
    print_warning "iOS Firebase configuration not found"
fi

# Check GitHub Actions workflow
print_status "Checking CI/CD configuration..."
if [[ -f ".github/workflows/ci-cd.yml" ]]; then
    print_success "GitHub Actions workflow found"
else
    print_error "GitHub Actions workflow not found"
fi

# Try a debug build
print_status "Testing debug build..."
flutter build apk --debug --flavor dev
if [[ $? -eq 0 ]]; then
    print_success "Debug build successful"
else
    print_error "Debug build failed"
fi

print_success "Setup verification completed!"
print_status "Next steps:"
echo "1. Configure Firebase (add google-services.json and GoogleService-Info.plist)"
echo "2. Set up Android signing (create android/key.properties)"
echo "3. Configure iOS signing in Xcode"
echo "4. Set up GitHub secrets for CI/CD"
echo "5. Test release builds"