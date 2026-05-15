from enum import Enum
from pathlib import Path
from datetime import timedelta
from src.core.config import settings

BASE_DIR = Path(__file__).resolve().parent.parent.parent
TEMPLATE_DIR = BASE_DIR / "src" / "templates"
TEMPLATE_PDF_DIR = BASE_DIR / "src" / "templates" 
PDF_TEMP_DIR = "/tmp"

_DEFAULT_ACCESS_TOKEN_EXPIRY = timedelta(minutes=15)
_BLACKLIST_TTL_SECONDS = 86_400

WEATHER_URL = f"https://api.openweathermap.org/data/2.5/weather?q=Cairo&appid={settings.WEATHER_API_KEY}&units=metric"

class Default_Message_For_Emergency:
    body = "Emergency Alert: Unusual Eye Movement Detected. Please check on the user immediately."


class ActionTypeEnum(str, Enum):
    ON = "on"
    OFF = "off"
    ADJUST = "adjust"