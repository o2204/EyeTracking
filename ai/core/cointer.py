from typing import Annotated

from fastapi import Depends

from ai.clients.cohere_client import CohereClient


def get_cohere_client() -> CohereClient:
    return CohereClient()

CohereDep = Annotated[
    CohereClient,
    Depends(get_cohere_client)
]