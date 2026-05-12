from typing import List, Optional

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore


class SchedulerService:
    def __init__(self, database_url: str):

        jobstores = {
            "default": SQLAlchemyJobStore(
                url=database_url
            )
        }

        self.scheduler = AsyncIOScheduler(jobstores=jobstores, timezone="UTC")
    
    def start(self):
        if not self.scheduler.running:
            self.scheduler.start()
    
    def add_daily_job(self, func, hour: int, minute: int, job_id: str, args: Optional[List] = None):
        self.scheduler.add_job(
            func,
            trigger="cron",
            hour=hour,
            minute=minute,
            id=job_id,
            args=args or [],
            replace_existing=True
        )