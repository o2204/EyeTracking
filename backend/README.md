# EyeTracking Backend 

The backend for VisionGate, an AI-powered Eye Tracking system designed for hands-free smart home control. Built with FastAPI, it handles user authentication, gaze data processing, administrative tasks, and IoT integration via MQTT.

## Tech Stack

- **Framework:** [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **Database:** SQLAlchemy / SQLModel
- **Cache/Session:** Redis (Token Blacklisting)
- **IoT Protocol:** MQTT (for device control)
- **AI/ML:** DeepFace / InsightFace (Face Recognition)
- **Architecture:** Layered Architecture (Routers, Services, Models, Schemas)

## Project Structure

```text
backend/
├── ai/                 # AI models and recognition logic
├── migrations/         # Database migration files (Alembic)
├── shared/             # Shared utilities and helpers
├── src/
│   ├── clients/        # DB and Redis clients
│   ├── core/           # Configuration and security settings
│   ├── models/         # Database models
│   ├── routers/        # API endpoints (User, Gaze, Admin, Analysis)
│   ├── schemas/        # Pydantic validation schemas
│   ├── services/       # Business logic layer
│   ├── templates/      # HTML templates (Email, Reports)
│   └── main.py         # Application entry point
└── run_all.sh          # Startup script
```

## Getting Started

### Prerequisites

- Python 3.10+
- Redis Server
- PostgreSQL/SQLite (as configured)
- MQTT Broker (e.g., Mosquitto)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/o2204/EyeTracking.git
   cd EyeTracking/backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Environment Variables:**
   Create a `.env` file in the `backend` directory (refer to `src/core/config.py` for required variables).

### Running the Server

Start the FastAPI server using Uvicorn:

```bash
uvicorn src.main:app --reload
```

The API will be available at `http://localhost:8000`. You can access the interactive documentation at `http://localhost:8000/docs`.

## API Modules

- **User Router:** Authentication, profile management, and face verification.
- **Gaze Control Router:** Processing eye tracking data and triggering smart home actions.
- **Admin Router:** Dashboard stats, user management, and system logs.
- **Analysis Router:** Generating reports and analyzing usage patterns.

## Smart Home Integration

The backend communicates with IoT devices using **MQTT**. Actions like turning on a fan or light are published to specific topics (e.g., `home/fan`) which are then picked up by the hardware components.

---
*Developed as part of the EyeTracking Graduation Project.*
