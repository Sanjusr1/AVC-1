# AVC Flutter Build Script (PowerShell)
# This script handles building the Flutter app for different platforms and environments

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("android", "ios", "all")]
    [string]$Platform,
    
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug",
    
    [switch]$Clean,
    [switch]$NoAnalyze,
    [switch]$NoTest,
    [switch]$Help
)

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Show usage
function Show-Usage {
    Write-Host "AVC Flutter Build Script"
    Write-Host ""
    Write-Host "Usage: .\build.ps1 -Platform <android|ios|all> [OPTIONS]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Platform       Target platform (android, ios, all) [Required]"
    Write-Host "  -Environment    Environment (dev, staging, prod) [Default: dev]"
    Write-Host "  -BuildType      Build type (debug, release) [Default: debug]"
    Write-Host "  -Clean          Clean before build"
    Write-Host "  -NoAnalyze      Skip code analysis"
    Write-Host "  -NoTest         Skip tests"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build.ps1 -Platform android -Environment prod -BuildType release"
    Write-Host "  .\build.ps1 -Platform ios -BuildType debug -Clean"
    Write-Host "  .\build.ps1 -Platform all -Environment staging"
}

if ($Help) {
    Show-Usage
    exit 0
}

Write-Status "Starting AVC Flutter build..."
Write-Status "Platform: $Platform"
Write-Status "Environment: $Environment"
Write-Status "Build Type: $BuildType"

# Change to Flutter project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptPath "..")

try {
    # Clean if requested
    if ($Clean) {
        Write-Status "Cleaning project..."
        flutter clean
        flutter pub get
    }

    # Get dependencies
    Write-Status "Getting dependencies..."
    flutter pub get

    # Generate code
    Write-Status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs

    # Run code analysis
    if (-not $NoAnalyze) {
        Write-Status "Running code analysis..."
        flutter analyze
        
        Write-Status "Checking code formatting..."
        dart format --set-exit-if-changed .
    }

    # Run tests
    if (-not $NoTest) {
        Write-Status "Running tests..."
        flutter test --coverage
    }

    # Build function for Android
    function Build-Android {
        Write-Status "Building Android ($BuildType)..."
        
        if ($BuildType -eq "release") {
            # Check if signing configuration exists
            if (-not (Test-Path "android/key.properties")) {
                Write-Warning "No signing configuration found. Creating unsigned release build."
                flutter build apk --release --flavor $Environment
            } else {
                flutter build appbundle --release --flavor $Environment
                flutter build apk --release --flavor $Environment
            }
        } else {
            flutter build apk --debug --flavor $Environment
        }
        
        Write-Success "Android build completed!"
    }

    # Build function for iOS
    function Build-iOS {
        Write-Status "Building iOS ($BuildType)..."
        
        if (-not $IsMacOS) {
            Write-Error "iOS builds are only supported on macOS."
            exit 1
        }
        
        if ($BuildType -eq "release") {
            flutter build ios --release --no-codesign
            Write-Status "Building iOS archive..."
            Set-Location ios
            xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath build/Runner.xcarchive archive
            Set-Location ..
        } else {
            flutter build ios --debug --no-codesign
        }
        
        Write-Success "iOS build completed!"
    }

    # Execute builds based on platform
    switch ($Platform) {
        "android" { Build-Android }
        "ios" { Build-iOS }
        "all" { 
            Build-Android
            Build-iOS
        }
    }

    Write-Success "Build process completed successfully!"

    # Show build artifacts
    Write-Status "Build artifacts:"
    if ($Platform -eq "android" -or $Platform -eq "all") {
        Write-Host "  Android APK: build/app/outputs/flutter-apk/"
        if ($BuildType -eq "release" -and (Test-Path "android/key.properties")) {
            Write-Host "  Android AAB: build/app/outputs/bundle/release/"
        }
    }

    if (($Platform -eq "ios" -or $Platform -eq "all") -and $IsMacOS) {
        Write-Host "  iOS App: build/ios/iphoneos/"
        if ($BuildType -eq "release") {
            Write-Host "  iOS Archive: ios/build/Runner.xcarchive"
        }
    }

} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}