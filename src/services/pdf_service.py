from jinja2 import Environment, FileSystemLoader, select_autoescape
from weasyprint import HTML

from src.core.constant_manger import TEMPLATE_PDF_DIR


class PDFService:
    def __init__(self):
        self.env = Environment(
            loader=FileSystemLoader(str(TEMPLATE_PDF_DIR),
            autoescape= select_autoescape(['html', 'xml']))
        )
    
    def generate_pdf_bytes(self, html_content: str) -> bytes:
        return HTML(string=html_content).write_pdf()