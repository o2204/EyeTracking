import json
from crewai.tools import tool

from shared.analysis_schema import RecommendationSchema

def make_analysis_tool(cohere_client):

    @tool("User Behavior Analysis Tool")
    def analyze(data: str) -> dict:
        try:
            parsed_data = json.loads(data)

            result = cohere_client.analyze_behavior(
                parsed_data,
                RecommendationSchema
            )

            return result.model_dump()

        except Exception as e:
            return {
                "error": str(e)
            }

    return analyze