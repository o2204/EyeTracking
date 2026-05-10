from zxcvbn import zxcvbn


def validate_password(password: str, confirm_password: str):
    errors = []

    if password != confirm_password:
        errors.append("Passwords do not match.")

    if len(password) < 8:
        errors.append("Password must be at least 8 characters long.")

    result = zxcvbn(password)
    if result["score"] < 3:
        errors.append("Password is too weak.")

    return errors