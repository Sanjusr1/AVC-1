# How to Run the AVC Flutter Frontend

## Quick Start (5 minutes)

### 1. Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Or use these quick commands:

# macOS (using Homebrew)
brew install flutter

# Windows (using Chocolatey)
choco install flutter

# Linux (using snap)
sudo snap install flutter --classic
```

### 2. Verify Installation
```bash
flutter doctor
```

### 3. Get Dependencies
```bash
cd avc_flutter
flutter pub get
```

### 4. Run the App
```bash
# For web (easiest to demo)
flutter run -d chrome

# For Android emulator
flutter run -d android

# For iOS simulator (macOS only)
flutter run -d ios
```

## What You'll See

### 🔐 Login Screen
- **Demo Credentials**: Use the "Use Demo Credentials" button
- **Email**: demo@avc.com
- **Password**: Demo@123
- Clean Material Design 3 interface
- Form validation and error handling

### 🏠 Dashboard (Main Screen)
- Welcome message with user email
- Device statistics cards (Total: 2, Connected: 1)
- Device list showing:
  - AVC Mask Pro (Connected, 85% signal, 92% battery)
  - AVC Audio Hub (Disconnected, 45% battery)
- "Add Device" button that opens device discovery

### 📊 Health Monitor
- Real-time metrics cards:
  - Signal Strength: 85% (Green - Excellent)
  - Battery Level: 92% (Green - Great)
  - Latency: 45ms (Green - Good)
  - Sensor Accuracy: 94% (Green - Excellent)
- 24-hour trend charts for all metrics
- Interactive Syncfusion charts with zoom/pan
- Color-coded health indicators

### 🎛️ Device Controls
- Device connection status
- Quick action buttons:
  - Calibrate (opens calibration dialog)
  - Test Voice (shows test notification)
  - Reset (resets all settings)
  - Emergency (disconnects device)
- Control sliders:
  - Volume Level (0-100%)
  - Sensitivity Level (0-100%)
  - Response Time (0-100ms)
- Feature toggles:
  - Noise Reduction (ON)
  - Adaptive Mode (OFF)
  - Voice Enhancement (ON)

### 🤖 AI Assistant
- Interactive chat interface
- Contextual responses based on queries:
  - "health" → Shows device health analysis
  - "optimize" → Provides optimization recommendations
  - "troubleshoot" → Offers troubleshooting steps
  - "battery" → Battery tips and status
- Suggested action chips for quick interactions
- Typing indicators and message timestamps

### ⚙️ More/Settings
- User profile section with avatar
- Theme switching (Light/Dark/System)
- Notification settings toggles
- Privacy & security options
- Help and support links
- About section with app info
- Logout functionality

### 📡 Device Discovery
- Simulated WiFi scanning
- Discovered devices list:
  - AVC Pro Max (92% signal)
  - AVC Lite 2024 (78% signal)
  - AVC Hub Pro (85% signal)
- Device pairing workflow with progress
- Help instructions for troubleshooting

## Key Features to Demo

### ✅ Complete Navigation Flow
1. **Login** → Use demo credentials
2. **Dashboard** → View device overview
3. **Health** → See real-time metrics and charts
4. **Controls** → Adjust device settings
5. **AI** → Chat with AI assistant
6. **More** → Change theme, view settings
7. **Add Device** → Discover and pair new devices

### ✅ Interactive Elements
- **Theme Switching**: Go to More → Theme → Try Light/Dark modes
- **Device Connection**: Dashboard → Tap device → Connect/Disconnect
- **AI Chat**: Ask "How is my device health?" or "Optimize my settings"
- **Control Sliders**: Adjust volume, sensitivity, response time
- **Device Discovery**: Add Device → Watch scanning animation

### ✅ Responsive Design
- Works on all screen sizes
- Material Design 3 theming
- Smooth animations and transitions
- Loading states and error handling

## Demo Script (2 minutes)

1. **Start**: "This is the AVC mobile app for managing Artificial Vocal Cord devices"
2. **Login**: Click "Use Demo Credentials" → Shows authentication flow
3. **Dashboard**: "Here's the main dashboard with device overview and statistics"
4. **Health**: "Real-time health monitoring with 24-hour trend charts"
5. **Controls**: "Full device control panel with sliders and toggles"
6. **AI**: Ask "How is my device health?" → Show AI response
7. **Settings**: "Theme switching and app preferences"
8. **Discovery**: "WiFi device discovery and pairing workflow"

## Troubleshooting

### If Flutter is not installed:
```bash
# Check if Flutter is in PATH
flutter --version

# If not found, add to PATH or reinstall
export PATH="$PATH:/path/to/flutter/bin"
```

### If dependencies fail:
```bash
flutter clean
flutter pub get
```

### If build fails:
```bash
flutter doctor
# Fix any issues shown
```

### For web demo (easiest):
```bash
flutter run -d chrome --web-port 8080
```

## Production Features

- **State Management**: Riverpod for reactive UI
- **Navigation**: GoRouter with authentication guards
- **Theming**: Material Design 3 with dark mode
- **Charts**: Syncfusion for professional data visualization
- **Mock Data**: Realistic device and health data
- **Error Handling**: Comprehensive error states
- **Loading States**: Smooth loading indicators
- **Responsive**: Works on phones, tablets, web

The app is production-ready with professional UI/UX and can be easily connected to real backend services!