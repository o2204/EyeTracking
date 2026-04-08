from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from fastapi import HTTPException, status

from src.clients.ai_client.ai_client import AIClient
from src.core.logger import setup_logger
from src.models.devices_model import DevicesModel
from src.models.recommendation_model import RecommendationModel
from src.models.user_actions_model import UserAction
from src.models.user_model import UserModel
from src.schemas.analysis_schema import UserActionCreate
from src.services.base_service import BaseService
from src.services.pdf_service import PDFService
from src.services.notification_service import NotificationService


class AnalysisService(BaseService):
    def __init__(self, session: AsyncSession, ai_client: AIClient, notification_service: NotificationService, pdf_service: PDFService):
        super().__init__(UserAction, session)
        self.ai_client = ai_client
        self.notification_service = notification_service
        self.pdf_service = pdf_service
        self.logger = setup_logger("Analysis Service")
    
    async def _get_user(self, user_id):
        stmt = select(UserModel).where(UserModel.id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one()
    
    # Create User Action
    async def create_user_action(self, user_id, data: UserActionCreate):

        stmt = select(DevicesModel).where(
            DevicesModel.id == data.device_id,
            DevicesModel.user_id == user_id
        )

        result = await self.session.execute(stmt)
        device = result.scalar_one_or_none()

        if not device:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Device not found"
            )

        action = UserAction(
            user_id=user_id,
            device_id=data.device_id,
            action=data.action,
            value=data.value,
            timestamp=datetime.utcnow()
        )

        return await self._add(action)
    
    # Get last 2 weeks
    async def get_user_actions_last_2weeks(self, user_id):
        two_weeks_ago = datetime.utcnow() - timedelta(days=14)

        stmt = select(UserAction).where(
            UserAction.user_id == user_id,
            UserAction.timestamp >= two_weeks_ago
        )

        result = await self.session.execute(stmt)
        return result.scalars().all()
    
    # Format data for Agent 
    def _format_actions(self, actions):
        return [
            {
                "device": action.device.name,
                "action": action.action.value,
                "time": action.timestamp.strftime("%H:%M")
            }
            for action in actions
        ]
    
    # Analysis user
    async def analyze_user(self, user_id):
        pdf_path = f"/tmp/report_{user_id}.pdf"

        actions = await self.get_user_actions_last_2weeks(user_id)

        if not actions:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No user actions found"
            )

        user = await self._get_user(user_id)

        formatted = self._format_actions(actions)

        self.logger.info(f"Starting analysis for user {user_id}")

        try:
            result = await self.ai_client.analyze(formatted)
            
            if not result or "recommendations" not in result:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Invalid response from AI service"
                )
            
            saved = [
                RecommendationModel(
                    user_id=user_id,
                    device=rec["device"],
                    action=rec["action"],
                    time=rec["time"],
                    recommendation=rec["recommendation"]
                )
                for rec in result["recommendations"]
            ]

            self.session.add_all(saved)
            await self.session.commit()

            # Generate PDF
            try:
                self.pdf_service.generate_pdf(
                    "analysis_pdf.html",
                    {
                        "username": user.name,
                        "actions": formatted,
                        "recommendations": result["recommendations"]
                    },
                    pdf_path 
                )

                # Send Email with PDF 
                self.notification_service.send_email_with_pdf(
                    user.email,
                    "Your Smart Home Analysis Report",
                    "Please find attached your report",
                    pdf_path
                )
            except Exception as e:
                self.logger.warning(f"Post-processing failed: {str(e)}")
            
            return saved

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Analysis failed: {str(e)}"
            )
            
    async def make_decision(self, user_id, recommendation_id, decision):
        stmt = select(RecommendationModel).where(
            RecommendationModel.id == recommendation_id,
            RecommendationModel.user_id == user_id
        )

        result = await self.session.execute(stmt)
        recommendation = result.scalar_one_or_none()

        if not recommendation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Recommendation not found"
            )
        
        recommendation.status == decision.status

        await self.session.commit()
        await self.session.refresh(recommendation)

        return recommendation