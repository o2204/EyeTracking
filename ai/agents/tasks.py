from crewai import Task


def create_analysis_task(agent, data):

    return Task(
        description=f"""
        Analyze the user's device usage data.

        Data:
        {data}

        Use the available tool to generate smart recommendations.
        """,
        agent=agent,
        expected_output="JSON recommendations"
    )