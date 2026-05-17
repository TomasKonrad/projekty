import sqlite3
from dataclasses import dataclass
from typing import Optional
from passlib.context import CryptContext
from repositories.users import get_user_by_username
from repositories.users import insert_user

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


@dataclass
class User:
    id: int
    username: str
    role: str


class AuthService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def authenticate(self, username: str, password: str) -> Optional[User]:
        user = get_user_by_username(self.conn, username)
        if not user:
            return None
        if not pwd_context.verify(password, user["password_hash"]):
            return None
        return User(id=user["id"], username=user["username"], role=user["role"])

    def hash_password(self, password: str) -> str:
        return pwd_context.hash(password)

    def register_user(self, username: str, email: str, password: str):
        existing_user = get_user_by_username(self.conn, username)
        if existing_user:
            raise ValueError("Uživatel s takovým jménem/emailem již existuje")
        hashed_password = pwd_context.hash(password)
        user_id=insert_user(
            conn=self.conn,
            username=username,
            email=email,
            password_hash=hashed_password,
            role="user"
        )
        return user_id
