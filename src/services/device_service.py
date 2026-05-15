import uuid
from typing import List
from sqlalchemy import select
from src.models.devices_model import DevicesModel
from src.schemas.device_schema import DeviceCreate, DeviceUpdate
from src.services.base_service import BaseService

class DeviceService(BaseService):
    def __init__(self, session):
        super().__init__(DevicesModel, session)

    async def create_device(self, device_data: DeviceCreate, user_id: uuid.UUID) -> DevicesModel:
        device = DevicesModel(
            name=device_data.name,
            type=device_data.type,
            status=device_data.status,
            accessibility_features=device_data.accessibility_features,
            user_id=user_id
        )
        return await self._add(device)

    async def get_user_devices(self, user_id: uuid.UUID) -> List[DevicesModel]:
        query = select(DevicesModel).where(DevicesModel.user_id == user_id)
        result = await self.session.execute(query)
        return result.scalars().all()

    async def get_device(self, device_id: uuid.UUID) -> DevicesModel:
        return await self._get(device_id)

    async def update_device(self, device_id: uuid.UUID, device_data: DeviceUpdate) -> DevicesModel:
        device = await self._get(device_id)
        if not device:
            return None
        
        update_data = device_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(device, key, value)
        
        return await self._update(device)

    async def delete_device(self, device_id: uuid.UUID) -> bool:
        device = await self._get(device_id)
        if not device:
            return False
        await self._delete(device)
        return True
