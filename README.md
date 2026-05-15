# Eye Tracking Project

A sophisticated, computer vision-based system designed to track user gaze and provide hands-free control for smart environments. This graduation project integrates real-time AI analysis with a cross-platform Flutter frontend and a robust FastAPI backend.

##  Overview

The Eye Tracking Project is an end-to-end solution that detects and tracks user eye movements using standard camera hardware. By analyzing pupil position and gaze direction, the system allows users to interact with digital interfaces and smart home devices simply by looking at them.

##  Key Features

- **Real-time Gaze Tracking:** High-precision tracking using advanced computer vision models.
- **Smart Home Integration:** Control connected devices (lights, smart appliances) via gaze interaction.
- **AI-Powered Analysis:** Dedicated AI microservice for processing and analyzing gaze patterns.
- **Admin Dashboard:** Comprehensive management interface for users and devices.
- **Cross-Platform UI:** Modern, responsive interface built with Flutter (Web/Desktop support).
- **Secure Authentication:** OAuth2-based authentication with session management and Redis-backed token blacklisting.
- **Face Recognition Login:** Seamless, hands-free login using DeepFace technology.

##  Architecture

The system follows a modern layered architecture:

- **Frontend (UI):** Built with **Flutter**, handling camera input, face detection (MLKit), and the interactive dashboard.
- **Backend API:** A **FastAPI** service managing business logic, user data, device state, and database interactions.
- **AI Microservice:** A specialized **FastAPI** service dedicated to heavy AI computations and data analysis.
- **Database Layer:** **PostgreSQL** for persistent storage and **Redis** for caching and security.

##  Tech Stack

### Frontend
- **Framework:** Flutter
- **AI Integration:** Google MLKit (Face Detection)
- **Networking:** HTTP & WebSockets
- **UI Components:** Google Fonts, Fl Chart, Flutter Map

### Backend & AI
- **Language:** Python 3.10+
- **Web Framework:** FastAPI
- **Database:** SQLAlchemy (PostgreSQL), Redis
- **AI/ML:** TensorFlow, OpenCV, Scikit-Learn, DeepFace
- **Auth:** JWT, Passlib (Bcrypt), Google Auth

##  Setup & Installation

### Prerequisites
- Python 3.10+
- Flutter SDK
- PostgreSQL & Redis

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/o2204/EyeTracking.git
   cd EyeTracking
   ```

2. **Install Backend Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Install Frontend Dependencies:**
   ```bash
   cd ui
   flutter pub get
   cd ..
   ```

## Running the Project

The project includes a convenience script to start all services simultaneously:

```bash
chmod +x run_all.sh
./run_all.sh
```

This will launch:
- **Backend API:** `http://localhost:8000`
- **AI Service:** `http://localhost:8001`
- **Frontend Web:** `http://localhost:3000`

---
*Developed as a Graduation Project*
