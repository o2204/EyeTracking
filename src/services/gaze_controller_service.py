import joblib
import asyncio
import cv2
import mediapipe as mp
from fastapi import WebSocketDisconnect

from src.services.camera_manger import CameraManager
from src.services.blink_detector_service import BlinkDetector


class GazeControllerService:

    def __init__(self, user_id: str):
        self.prev_x = 0
        self.prev_y = 0
        self.blink_detector = BlinkDetector()

        self.face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)

        # Load ML models
        try:
            self.model_x = joblib.load(f"ml_models/model_x_{user_id}.pkl")
            self.model_y = joblib.load(f"ml_models/model_y_{user_id}.pkl")
            print("Model loaded successfully")
        except Exception:
            self.model_x = None
            self.model_y = None
            print("No model found, using raw gaze")

    # Blink detection
    def detect_blink(self, landmarks):
        top = landmarks[159]
        bottom = landmarks[145]
        eye_distance = abs(top.y - bottom.y)
        return eye_distance < 0.01

    async def run(self, websocket):
        try:
            while True:
                # Receive image bytes from client
                data = await websocket.receive_bytes()
                
                # Decode image from bytes
                import numpy as np
                nparr = np.frombuffer(data, np.uint8)
                frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

                if frame is None:
                    continue

                frame = cv2.flip(frame, 1)
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

                output = self.face_mesh.process(rgb_frame)

                if output.multi_face_landmarks:
                    landmarks = output.multi_face_landmarks[0].landmark

                    # Raw gaze
                    gaze_point = landmarks[475]
                    x = gaze_point.x
                    y = gaze_point.y

                    # Smoothing
                    smooth_x = self.prev_x * 0.7 + x * 0.3
                    smooth_y = self.prev_y * 0.7 + y * 0.3

                    self.prev_x = smooth_x
                    self.prev_y = smooth_y

                    # ML prediction (if model exists, otherwise use raw gaze)
                    if self.model_x and self.model_y:
                        pred_x = self.model_x.predict([[smooth_x, smooth_y]])[0]
                        pred_y = self.model_y.predict([[smooth_x, smooth_y]])[0]
                    else:
                        pred_x = smooth_x
                        pred_y = smooth_y

                    # Blink
                    is_blink = self.detect_blink(landmarks)
                    action = self.blink_detector.update(is_blink)

                    response = {
                        "x": float(pred_x),
                        "y": float(pred_y),
                        "blink": is_blink
                    }

                    # Double blink → click
                    if action == "double_blink":
                        response["action"] = "click"

                    await websocket.send_json(response)

        except WebSocketDisconnect:
            print("Client disconnected")

        except Exception as e:
            print(f"Error: {e}")

        finally:
            pass