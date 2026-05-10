import requests

from fastapi import APIRouter, HTTPException

from src.core.constant_manger import settings


weather_router = APIRouter(
    prefix="/weather",
    tags=["Weather"]
)


@weather_router.get("/")
def get_weather():

    response = requests.get(
        f"https://api.openweathermap.org/data/2.5/weather"
        f"?q=Cairo"
        f"&appid={settings.WEATHER_API_KEY}"
        f"&units=metric"
    )

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail="Failed to fetch weather data"
        )

    data = response.json()
    temp = data["main"]["temp"]

    if temp > 25:
        color_temp = "Cool"
    elif temp > 15:
        color_temp = "Neutral"
    else:
        color_temp = "Warm"

    return {
        "temperature": temp,
        "humidity": data["main"]["humidity"],
        "color_temp": color_temp
    }