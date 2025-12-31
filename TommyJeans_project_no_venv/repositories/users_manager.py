# app/repositories/users_manager.py
import sqlite3
from typing import List, Dict, Any


def list_all_users(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    rows=conn.execute(
        """
        SELECT username, id, role FROM users WHERE id > 1
        """
    ).fetchall()
    return [dict(r) for r in rows]

def change_user_role(
        conn: sqlite3.Connection,
        user_id: int,
        role: str
) -> None:
    conn.execute(
        """
        UPDATE users
        SET role = ?
        WHERE id = ?
        """,
        (role, user_id,),
    )
    conn.commit()

#TODO přidat mazání uživatele z databáze
def delete_user(conn: sqlite3.Connection, user_id: int) -> None:
    conn.execute(
        """
        DELETE FROM users WHERE id = ?
        """, (user_id,)
    )
    conn.commit()
    # upravit na bool?

def all_user_count(conn: sqlite3.Connection) -> int:
    cur = conn.execute(
        """
        SELECT COUNT(*) FROM users
        """
    )
    return cur.fetchone()[0]