import cohere
from pydantic import BaseModel
import json
from typing import Optional, Type

from fastapi import HTTPException, status

from ai.core.config import settings
from ai.core.constant_manger import (
    SYSTEM_PROMPT,
    ANALYSIS_PROMPT_TEMPLATE,
    LLMConstants
)

import logging

logger = logging.getLogger(__name__)


class CohereClient:
    def __init__(self, api_key: Optional[str] = None):
        self.client = cohere.Client(api_key or settings.COHERE_API)
        self.model_name = LLMConstants.CoHere_Model
        self.logger = logger

    # Main Analysis Method
    def analyze_behavior(
        self,
        formatted_data,
        response_model: Type[BaseModel],
        temperature: float = LLMConstants.LLM_DEFAULT_TEMPERATURE,
    ) -> BaseModel:
        try:
            # normalize input for better LLM understanding
            formatted_data_str = json.dumps(formatted_data, indent=2)

            prompt = self._build_analysis_prompt(formatted_data_str)

            response = self.client.generate(
                model=self.model_name,
                prompt=prompt,
                temperature=temperature,
                max_tokens=400 
            )

            text = response.generations[0].text.strip()

            parsed = self._parse_json(text)

            return response_model.model_validate(parsed)

        except Exception as e:
            self.logger.error(f"Cohere analysis error: {str(e)}")

            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Cohere analysis failed",
            )

    # Prompt Builder
    def _build_analysis_prompt(self, data: str) -> str:
        return f"""
{SYSTEM_PROMPT}

{ANALYSIS_PROMPT_TEMPLATE.format(formatted_data=data)}

IMPORTANT:
- Return ONLY valid JSON
- No explanation
- No markdown
"""

    # Robust JSON Parser
    def _parse_json(self, text: str):
        try:
            return json.loads(text)

        except json.JSONDecodeError:
            self.logger.warning("Invalid JSON, attempting cleanup...")

            cleaned = (
                text.strip()
                .replace("```json", "")
                .replace("```", "")
            )

            try:
                return json.loads(cleaned)

            except Exception:
                self.logger.error("Failed to parse JSON from Cohere response")

                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Invalid JSON returned from Cohere",
                )