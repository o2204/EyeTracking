import smtplib

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

from fastapi import BackgroundTasks
from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType
from pydantic import EmailStr

from twilio.rest import Client

from src.core.config import notification_settings
from src.core.constant_manger import TEMPLATE_DIR, Default_Message_For_Emergency


class NotificationService:
    def __init__(self, tasks: BackgroundTasks):

        self.tasks = tasks

        mail_config_data = notification_settings.model_dump(
            exclude={
                "TWILIO_SID",
                "TWILIO_AUTH_TOKEN",
                "TWILIO_NUMBER",
            }
        )

        self.fastmail = FastMail(
            ConnectionConfig(
                **mail_config_data,
                TEMPLATE_FOLDER=TEMPLATE_DIR,
            )
        )

        self.twilio_client = Client(
            notification_settings.TWILIO_SID,
            notification_settings.TWILIO_AUTH_TOKEN
        )
    
    async def send_email(
        self,
        recipients: list[EmailStr],
        subject: str,
        body: str,
    ):
        self.tasks.add_task(
            self.fastmail.send_message,
            message=MessageSchema(
                recipients=recipients,
                subject=subject,
                body=body,
                subtype=MessageType.plain,
            )
        )

    async def send_email_with_template(
        self,
        recipients: list[EmailStr],
        subject: str,
        context: dict,
        template_name: str,
    ):
        self.tasks.add_task(
            self.fastmail.send_message,
            message=MessageSchema(
                recipients=recipients,
                subject=subject,
                template_body=context,
                subtype=MessageType.html,
            ),
            template_name=template_name,
        )
    
    async def send_sms(self, to: str, body: str):
        await self.twilio_client.messages.create_async(
            from_=notification_settings.TWILIO_NUMBER,
            to=to,
            body=body,
        )       
    
    async def send_emergency_sms(self, to: str, body: Default_Message_For_Emergency):
        await self.send_sms(to, body.body)

    async def send_email_with_pdf(self, to_email, subject, body, file_path):
        msg = MIMEMultipart()
        msg["From"] = self.from_email()
        msg["To"] = to_email
        msg["Subject"] = subject

        msg.attach(MIMEText(body, "plain"))

        # attach PDF 
        with open(file_path, "rb") as f:
            part = MIMEBase("application", "octet-stream")
            part.set_payload(f.read())
        
        encoders.encode_base64(part)
        part.add_header(
            "Content-Disposition",
            "attachment; filename=report.pdf"
        )
        
        msg.attach(part)
        with smtplib.SMTP(self.host, self.port) as server:
            server.starttls()
            server.login(self.username, self.password)
            server.send_message(msg)
