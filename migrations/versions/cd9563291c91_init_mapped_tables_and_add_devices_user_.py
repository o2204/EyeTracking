"""init Mapped tables and add devices, user_actions

Revision ID: cd9563291c91
Revises: 1332d7f43e41
Create Date: 2026-04-05

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers
revision: str = 'cd9563291c91'
down_revision: Union[str, None] = '1332d7f43e41'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 🔥 USERS (new table)
    op.create_table(
        'users',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('email_verified', sa.Boolean(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('password_hash', sa.String(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )

    op.create_index('ix_users_email', 'users', ['email'], unique=True)
    op.create_index('ix_users_id', 'users', ['id'])

    # 🔥 DEVICES
    op.create_table(
        'devices',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('type', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # 🔥 USER ACTIONS
    op.create_table(
        'user_actions',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('device_id', sa.UUID(), nullable=False),
        sa.Column(
            'action',
            sa.Enum('ON', 'OFF', 'ADJUST', name='action_type_enum'),
            nullable=False
        ),
        sa.Column('value', sa.String(), nullable=True),
        sa.Column('timestamp', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id']),
        sa.ForeignKeyConstraint(['device_id'], ['devices.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # 🔥 INDEXES
    op.create_index('ix_user_actions_timestamp', 'user_actions', ['timestamp'])
    op.create_index('ix_user_actions_user_id', 'user_actions', ['user_id'])
    op.create_index('ix_user_actions_device_id', 'user_actions', ['device_id'])

    op.create_index(
        'ix_user_device_time',
        'user_actions',
        ['user_id', 'device_id', 'timestamp']
    )

    # 🔥 IMPORTANT FIX (ORDER FIXED)

    # 1. فك FK القديم من calibration_points → user
    op.drop_constraint(
        'calibration_points_user_id_fkey',
        'calibration_points',
        type_='foreignkey'
    )

    # 2. اربطه بالجدول الجديد users
    op.create_foreign_key(
        None,
        'calibration_points',
        'users',
        ['user_id'],
        ['id']
    )

    # 3. امسح الجدول القديم user
    op.drop_index('ix_user_email', table_name='user')
    op.drop_index('ix_user_id', table_name='user')
    op.drop_table('user')

    # 🔥 ADMIN FIX
    op.alter_column('admin', 'is_superuser',
                    existing_type=sa.BOOLEAN(),
                    nullable=False)

    op.alter_column('admin', 'email_verified',
                    existing_type=sa.BOOLEAN(),
                    nullable=False)

    op.alter_column('admin', 'must_reset_password',
                    existing_type=sa.BOOLEAN(),
                    nullable=False)

    op.alter_column('admin', 'reset_email_sent',
                    existing_type=sa.BOOLEAN(),
                    nullable=False)


def downgrade() -> None:
    # 🔥 DROP INDEXES
    op.drop_index('ix_user_device_time', table_name='user_actions')
    op.drop_index('ix_user_actions_device_id', table_name='user_actions')
    op.drop_index('ix_user_actions_user_id', table_name='user_actions')
    op.drop_index('ix_user_actions_timestamp', table_name='user_actions')

    # 🔥 DROP TABLES
    op.drop_table('user_actions')
    op.drop_table('devices')

    op.drop_index('ix_users_id', table_name='users')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_table('users')

    # 🔥 RESTORE OLD FK
    op.drop_constraint(None, 'calibration_points', type_='foreignkey')

    op.create_foreign_key(
        'calibration_points_user_id_fkey',
        'calibration_points',
        'user',
        ['user_id'],
        ['id']
    )

    # 🔥 RESTORE OLD USER TABLE
    op.create_table(
        'user',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('email_verified', sa.Boolean(), nullable=True),
        sa.Column('password_hash', sa.String(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )

    op.create_index('ix_user_id', 'user', ['id'])
    op.create_index('ix_user_email', 'user', ['email'], unique=True)

    # 🔥 ADMIN BACK
    op.alter_column('admin', 'reset_email_sent',
                    existing_type=sa.BOOLEAN(),
                    nullable=True)

    op.alter_column('admin', 'must_reset_password',
                    existing_type=sa.BOOLEAN(),
                    nullable=True)

    op.alter_column('admin', 'email_verified',
                    existing_type=sa.BOOLEAN(),
                    nullable=True)

    op.alter_column('admin', 'is_superuser',
                    existing_type=sa.BOOLEAN(),
                    nullable=True)