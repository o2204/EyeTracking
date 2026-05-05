"""make password_hash nullable

Revision ID: 1332d7f43e41
Revises: 615683abaf52
Create Date: 2026-04-05 02:33:48.240181

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '1332d7f43e41'
down_revision: Union[str, None] = '615683abaf52'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


# upgrade
def upgrade():
    op.alter_column(
        "admin",
        "password_hash",
        existing_type=sa.String(),
        nullable=True
    )


# downgrade
def downgrade():
    op.alter_column(
        "admin",
        "password_hash",
        existing_type=sa.String(),
        nullable=False
    )
