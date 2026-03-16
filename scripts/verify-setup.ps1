# AVC Flutter Setup Verification Script (PowerShell)
# This script verifies that the build environment is properly configured

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

Write-Status "Verifying AVC Flutter build setup..."

# Change to Flutter project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptPath "..")

try {
    # Check Flutter installation
    Write-Status "Checking Flutter installation..."
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        flutter --version
        Write-Success "Flutter is installed"
    } else {
        Write-Error "Flutter is not installed or not in PATH"
        exit 1
    }

    # Check Flutter doctor
    Write-Status "Running Flutter doctor..."
    flutter doctor

    # Check dependencies
    Write-Status "Checking dependencies..."
    flutter pub get

    # Check code generation
    Write-Status "Checking code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs

    # Check code analysis
    Write-Status "Running code analysis..."
    flutter analyze

    # Check formatting
    Write-Status "Checking code formatting..."
    try {
        dart format --set-exit-if-changed .
    } catch {
        Write-Warning "Code formatting issues found"
    }

    # Check tests
    Write-Status "Running tests..."
    flutter test

    # Check Android configuration
    Write-Status "Checking Android configuration..."
    if (Test-Path "android/app/build.gradle") {
        Write-Success "Android build.gradle found"
    } else {
        Write-Error "Android build.gradle not found"
    }

    if (Test-Path "android/key.properties") {
        Write-Success "Android signing configuration found"
    } else {
        Write-Warning "Android signing configuration not found (required for release builds)"
    }

    # Check iOS configuration (macOS only)
    if ($IsMacOS) {
        Write-Status "Checking iOS configuration..."
        if (Test-Path "ios/Runner/Info.plist") {
            Write-Success "iOS Info.plist found"
        } else {
            Write-Error "iOS Info.plist not found"
        }
        
        if (Test-Path "ios/ExportOptions.plist") {
            Write-Success "iOS ExportOptions.plist found"
        } else {
            Write-Warning "iOS ExportOptions.plist not found (required for distribution)"
        }
    } else {
        Write-Warning "iOS configuration check skipped (not on macOS)"
    }

    # Check Firebase configuration
    Write-Status "Checking Firebase configuration..."
    if (Test-Path "android/app/google-services.json") {
        Write-Success "Android Firebase configuration found"
    } else {
        Write-Warning "Android Firebase configuration not found"
    }

    if (Test-Path "ios/Runner/GoogleService-Info.plist") {
        Write-Success "iOS Firebase configuration found"
    } else {
        Write-Warning "iOS Firebase configuration not found"
    }

    # Check GitHub Actions workflow
    Write-Status "Checking CI/CD configuration..."
    if (Test-Path ".github/workflows/ci-cd.yml") {
        Write-Success "GitHub Actions workflow found"
    } else {
        Write-Error "GitHub Actions workflow not found"
    }

    # Try a debug build
    Write-Status "Testing debug build..."
    flutter build apk --debug --flavor dev
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Debug build successful"
    } else {
        Write-Error "Debug build failed"
    }

    Write-Success "Setup verification completed!"
    Write-Status "Next steps:"
    Write-Host "1. Configure Firebase (add google-services.json and GoogleService-Info.plist)"
    Write-Host "2. Set up Android signing (create android/key.properties)"
    Write-Host "3. Configure iOS signing in Xcode"
    Write-Host "4. Set up GitHub secrets for CI/CD"
    Write-Host "5. Test release builds"

} catch {
    Write-Error "Verification failed: $($_.Exception.Message)"
    exit 1
}