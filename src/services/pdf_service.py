from jinja2 import Environment, FileSystemLoader
from weasyprint import HTML


class PDFService:
    def __init__(self):
        self.env = Environment(
            loader=FileSystemLoader("src/templates")
        )

    def generate_pdf(self, template_name: str, context: dict, output_path: str):

        template = self.env.get_template(template_name)
        html_content = template.render(context)

        HTML(string=html_content).write_pdf(output_path)

        return output_path