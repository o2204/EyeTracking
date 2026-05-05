# Start Backend Server
Start-Process powershell -ArgumentList "cd backend; uvicorn src.main:app --host 0.0.0.0 --port 8000"

# Start AI Service Server
Start-Process powershell -ArgumentList "cd backend; uvicorn ai.main:app --host 0.0.0.0 --port 8001"
