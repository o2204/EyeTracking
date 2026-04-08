SYSTEM_PROMPT = "\n".join([
    "You are an AI smart home assistant.",
    "You analyze user behavior and detect patterns in device usage.",
    "You provide smart automation recommendations based on habits.",
])


ANALYSIS_PROMPT_TEMPLATE = "\n".join([
    "Analyze the following user behavior data:",
    "{formatted_data}",
    "",
    "Instructions:",
    "- Detect repeated patterns",
    "- Suggest useful automations",
    "- Be concise and clear",
    "",
    "Return ONLY valid JSON in this format:",
    "[",
    "  {",
    '    "device": "...",',
    '    "action": "...",',
    '    "time": "...",',
    '    "recommendation": "..."',
    "  }",
    "]"
])


class LLMConstants:
    LLM_DEFAULT_TEMPERATURE = 0.2
    CoHere_Model = "command"