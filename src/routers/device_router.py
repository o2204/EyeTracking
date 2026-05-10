from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from src.schemas.device_schema import DeviceCreate, DeviceResponse, DeviceUpdate
from src.core.cointer import DeviceServiceDep, UserDep
from src.models.devices_model import DevicesModel

device_router = APIRouter(prefix="/devices", tags=["Devices"])

@device_router.post("/", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def create_device(
    device: DeviceCreate,
    service: DeviceServiceDep,
    current_user: UserDep
):
    return await service.create_device(device, current_user.id)

@device_router.get("/", response_model=List[DeviceResponse])
async def get_my_devices(
    service: DeviceServiceDep,
    current_user: UserDep
):
    return await service.get_user_devices(current_user.id)

@device_router.get("/{device_id}", response_model=DeviceResponse)
async def get_device(
    device_id: str,
    service: DeviceServiceDep,
    current_user: UserDep
):
    device = await service.get_device(device_id)
    if not device or device.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    return device

@device_router.patch("/{device_id}", response_model=DeviceResponse)
async def update_device(
    device_id: str,
    device_update: DeviceUpdate,
    service: DeviceServiceDep,
    current_user: UserDep
):
    device = await service.get_device(device_id)
    if not device or device.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    
    return await service.update_device(device_id, device_update)

@device_router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(
    device_id: str,
    service: DeviceServiceDep,
    current_user: UserDep
):
    device = await service.get_device(device_id)
    if not device or device.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    
    await service.delete_device(device_id)
    return None
