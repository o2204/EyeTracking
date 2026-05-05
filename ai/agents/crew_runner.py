from crewai import Crew

from ai.agents.analysis_agent import create_analysis_agent
from ai.agents.tasks import create_analysis_task
from ai.agents.tools import make_analysis_tool


def run_analysis_flow(data, cohere_client):

    tool = make_analysis_tool(cohere_client)

    agent = create_analysis_agent(tool)

    task = create_analysis_task(agent, data)

    crew = Crew(
        agents=[agent],
        tasks=[task],
        verbose=True
    )

    result = crew.kickoff()

    return result