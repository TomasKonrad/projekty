# app/services/users_manager.py
import sqlite3
from typing import List, Dict, Any

from repositories.users_manager import list_all_users as repo_list_all_users
from repositories.users_manager import change_user_role as repo_change_user_role
from repositories.users_manager import delete_user as repo_delete_user
from repositories.users_manager import all_user_count as repo_all_user_count
class UsersManagerService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def list_all_users(self) -> List[Dict[str, Any]]:
        return repo_list_all_users(self.conn)

    def change_user_role(self, user_id: int, role: str) -> None:
        return repo_change_user_role(self.conn, user_id, role)

    def delete_user(self, user_id: int) -> None:
        return repo_delete_user(self.conn, user_id)

    def all_user_count(self)->int:
        return repo_all_user_count(self.conn)