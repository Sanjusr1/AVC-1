#!/bin/bash

# AVC Flutter Build Script
# This script handles building the Flutter app for different platforms and environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PLATFORM=""
ENVIRONMENT="dev"
BUILD_TYPE="debug"
CLEAN=false
ANALYZE=true
TEST=true

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --platform PLATFORM    Target platform (android, ios, all)"
    echo "  -e, --environment ENV       Environment (dev, staging, prod) [default: dev]"
    echo "  -t, --type TYPE            Build type (debug, release) [default: debug]"
    echo "  -c, --clean                Clean before build"
    echo "  --no-analyze               Skip code analysis"
    echo "  --no-test                  Skip tests"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -p android -e prod -t release"
    echo "  $0 -p ios -t debug --clean"
    echo "  $0 -p all -e staging"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        --no-analyze)
            ANALYZE=false
            shift
            ;;
        --no-test)
            TEST=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate platform
if [[ -z "$PLATFORM" ]]; then
    print_error "Platform is required. Use -p or --platform to specify."
    show_usage
    exit 1
fi

if [[ "$PLATFORM" != "android" && "$PLATFORM" != "ios" && "$PLATFORM" != "all" ]]; then
    print_error "Invalid platform: $PLATFORM. Must be android, ios, or all."
    exit 1
fi

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "prod" ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

# Validate build type
if [[ "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" ]]; then
    print_error "Invalid build type: $BUILD_TYPE. Must be debug or release."
    exit 1
fi

print_status "Starting AVC Flutter build..."
print_status "Platform: $PLATFORM"
print_status "Environment: $ENVIRONMENT"
print_status "Build Type: $BUILD_TYPE"

# Change to Flutter project directory
cd "$(dirname "$0")/.."

# Clean if requested
if [[ "$CLEAN" == true ]]; then
    print_status "Cleaning project..."
    flutter clean
    flutter pub get
fi

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Generate code
print_status "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run code analysis
if [[ "$ANALYZE" == true ]]; then
    print_status "Running code analysis..."
    flutter analyze
    
    print_status "Checking code formatting..."
    dart format --set-exit-if-changed .
fi

# Run tests
if [[ "$TEST" == true ]]; then
    print_status "Running tests..."
    flutter test --coverage
fi

# Build function for Android
build_android() {
    print_status "Building Android ($BUILD_TYPE)..."
    
    if [[ "$BUILD_TYPE" == "release" ]]; then
        # Check if signing configuration exists
        if [[ ! -f "android/key.properties" ]]; then
            print_warning "No signing configuration found. Creating unsigned release build."
            flutter build apk --release --flavor $ENVIRONMENT
        else
            flutter build appbundle --release --flavor $ENVIRONMENT
            flutter build apk --release --flavor $ENVIRONMENT
        fi
    else
        flutter build apk --debug --flavor $ENVIRONMENT
    fi
    
    print_success "Android build completed!"
}

# Build function for iOS
build_ios() {
    print_status "Building iOS ($BUILD_TYPE)..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS builds are only supported on macOS."
        exit 1
    fi
    
    if [[ "$BUILD_TYPE" == "release" ]]; then
        flutter build ios --release --no-codesign
        print_status "Building iOS archive..."
        cd ios
        xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath build/Runner.xcarchive archive
        cd ..
    else
        flutter build ios --debug --no-codesign
    fi
    
    print_success "iOS build completed!"
}

# Execute builds based on platform
case $PLATFORM in
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    all)
        build_android
        build_ios
        ;;
esac

print_success "Build process completed successfully!"

# Show build artifacts
print_status "Build artifacts:"
if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
    echo "  Android APK: build/app/outputs/flutter-apk/"
    if [[ "$BUILD_TYPE" == "release" && -f "android/key.properties" ]]; then
        echo "  Android AAB: build/app/outputs/bundle/release/"
    fi
fi

if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  iOS App: build/ios/iphoneos/"
    if [[ "$BUILD_TYPE" == "release" ]]; then
        echo "  iOS Archive: ios/build/Runner.xcarchive"
    fi
fi