import cv2


class CameraManager:
    _instance = None

    def __init__(self):
        self.cam = cv2.VideoCapture(0)

    @classmethod
    def get_camera(cls):
        if cls._instance is None:
            cls._instance = CameraManager()
        return cls._instance.cam