from enum import Enum
from pathlib import Path
from itsdangerous import URLSafeTimedSerializer

from src.core.config import settings

_serializer = URLSafeTimedSerializer(settings.JWT_SECRET)

BASE_DIR = Path(__file__).resolve().parent.parent.parent
TEMPLATE_DIR = BASE_DIR / "src" / "templates"
TEMPLATE_PDF_DIR = BASE_DIR / "src" / "templates" 
PDF_TEMP_DIR = "/tmp"

class Default_Message_For_Emergency:
    body = "Emergency Alert: Unusual Eye Movement Detected. Please check on the user immediately."


class ActionTypeEnum(str, Enum):
    ON = "on"
    OFF = "off"
    ADJUST = "adjust"