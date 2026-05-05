SYSTEM_PROMPT = "\n".join([
    "You are an AI smart home assistant.",
    "You analyze user behavior and detect patterns in device usage.",
    "You provide smart automation recommendations based on habits.",
])


ANALYSIS_PROMPT_TEMPLATE = "\n".join([
    "Analyze the following user behavior data:",
    "{formatted_data}",
    "",
    "Return ONLY valid JSON in this format:",
    "{",
    '  "recommendations": [',
    "    {",
    '      "device": "...",',
    '      "action": {',
    '         "type": "ON | OFF | SET_TEMPERATURE | SET_SPEED",',
    '         "value": 0 (optional)',
    "      },",
    '      "time": "HH:MM",',
    '      "recommendation": "..."',
    "    }",
    "  ]",
    "}"
])

class LLMConstants:
    LLM_DEFAULT_TEMPERATURE = 0.2
    CoHere_Model = "command"