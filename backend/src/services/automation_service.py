import datetime
import asyncio

from src.core.logger import setup_logger


class AutomationService:
    def __init__(self, scheduler_service, iot_service, device_service):
        self.scheduler = scheduler_service
        self.iot_service = iot_service
        self.device_service = device_service
        self.logger = setup_logger("AutomationService")

    async def handle_recommendation(self, recommendation):

        hour, minute = map(int, recommendation.time.split(":"))

        # Schedule the action
        self.scheduler.add_daily_job(
            self.execute_action,
            hour,
            minute,
            job_id=str(recommendation.id),
            args=[recommendation.device_id, recommendation.action]
        )
    
    async def execute_action(self, device_id, action):

        try:
            device = await self.device_service.get(device_id)
            self.logger.info(f"Executing action {action} on device {device.type} at {datetime.utcnow()}")

            await self._dispatch(device, action)

        except Exception as e:
            self.logger.error(f"Failed to log action execution: {e}")

            await asyncio.sleep(5)  # Wait before retrying
            await self._retry(device_id, action)
    
    async def _dispatch(self, device, action):
        handlers = {
            "AC": self._handle_ac,
            "Light": self._handle_light,
            "Fan": self._handle_fan,
            "TV": self._handle_tv
        }

        handler = handlers.get(device.type.upper())
        if not handler:
            self.logger.error(f"Unsupported device type: {device.type}")
            raise Exception(f"Unsupported device type: {device.type}")
        
        await handler(device, action)
        
    async def _handle_ac(self, device, action):
        if action.type == "ON":
            await self.iot_service.turn_on_ac(device.external_id)

        elif action.type == "OFF":
            await self.iot_service.turn_off_ac(device.external_id)

        elif action == "SET_TEMPERATURE":
            await self.iot_service.set_ac_temperature(device.external_id, action.value)

    async def _handle_light(self, device, action):
        if action.type == "ON":
            await self.iot_service.turn_on_light(device.external_id)

        elif action.type == "OFF":
            await self.iot_service.turn_off_light(device.external_id)

    async def _handle_fan(self, device, action):
        if action.type == "ON":
            await self.iot_service.turn_on_fan(device.external_id)

        elif action.type == "OFF":
            await self.iot_service.turn_off_fan(device.external_id)

        elif action == "SET_SPEED":
            await self.iot_service.set_fan_speed(device.external_id, action.value)  
    
    async def _handle_tv(self, device, action):
        if action.type == "ON":
            await self.iot_service.turn_on_tv(device.external_id)

        elif action.type == "OFF":
            await self.iot_service.turn_off_tv(device.external_id)

    async def _retry(self, device_id, action, retries=3):
        for attempt in range(retries):
            try:
                device = await self.device_service.get(device_id)
                await self._dispatch(device, action)

                self.logger.info(f"Retry success for {device_id} on attempt {attempt + 1}")
                return
    
            except Exception as e:
                self.logger.error(f"Retry {attempt + 1} failed for {device_id}: {str(e)}")
                await asyncio.sleep(2 ** attempt)  # Wait before next retry
        
        self.logger.error(f"All retries failed for action {action} on device {device_id}")