# Eye Tracking UI

VisionGate is a cutting-edge Flutter application that enables hands-free interaction through advanced eye-tracking technology. Designed for accessibility and modern smart home control, it allows users to navigate and control their environment using only their eyes.

## Key Features

- **Gaze-Based Navigation:** Control the app and smart home devices using eye movements.
- **AI Face Login:** Secure, hands-free authentication using face recognition.
- **Smart Home Dashboard:** Interactive controls for different rooms (Bedroom, Reception, etc.).
- **Voice Feedback:** Integrated Text-to-Speech (TTS) for accessibility.
- **Real-time Calibration:** Easy setup to ensure high accuracy for different users.
- **Admin Dashboard:** Comprehensive system monitoring and user management.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Multi-platform)
- **State Management:** Provider / Bloc (as implemented)
- **AI/Vision:** Google ML Kit (Face Detection)
- **Communication:** HTTP & WebSockets
- **Design:** Modern Glassmorphism & Dark/Light mode support

## Project Structure

```text
ui/
├── assets/             # Images, icons, and fonts
├── lib/
│   ├── features/       # Feature-based modules (Profile, Auth, etc.)
│   ├── routes/         # App routing configuration
│   ├── screens/        # UI Screens (Dashboard, Login, Room controls)
│   ├── services/       # API and Backend communication logic
│   ├── theme/          # Custom styling and animations
│   ├── widgets/        # Reusable UI components
│   └── main.py         # Entry point
└── pubspec.yaml        # Dependencies and assets configuration
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extension
- A device with a front-facing camera (for eye tracking)

### Installation

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the application:**
   ```bash
   flutter run
   ```

## System Integration

The UI communicates with the [VisionGate Backend](../backend) via:
- **REST API:** For authentication and data retrieval.
- **WebSockets:** For real-time eye tracking data transmission.
- **Local Storage:** Secure storage for authentication tokens.

## Screenshots & UI

The application features a premium dark-themed interface with glassmorphism effects, ensuring a futuristic and high-end user experience.

---
*Developed as part of the EyeTracking Graduation Project.*
