from crewai import Agent


def create_analysis_agent(tool):

    return Agent(
        role="Smart Home Analyst",
        goal="Analyze user behavior and suggest automation",
        backstory=(
            "You are an expert in analyzing smart home usage patterns "
            "and recommending automation based on user habits."
        ),
        tools=[tool], 
        verbose=True
    )