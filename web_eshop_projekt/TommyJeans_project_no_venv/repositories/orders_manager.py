#app/repositories/orders_manager.py
import sqlite3
from typing import List, Dict, Any

def list_all_orders(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    rows = conn.execute(
        """
        SELECT ord.id, ord.created_at, ord.total_price,ord.delivery_date,s.status_name
        FROM orders ord JOIN statuses s ON ord.status_id = s.id
            ORDER BY ord.created_at DESC
        """
    ).fetchall()
    return [dict(r) for r in rows]

def all_orders_count(conn: sqlite3.Connection) -> int:
    cur = conn.execute(
        """
        SELECT COUNT(*) FROM orders
        """
    )
    return cur.fetchone()[0]

def list_statuses(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT status_name FROM statuses ORDER BY id"
        ).fetchall()
    return [r[0] for r in rows]

def change_order_status(conn: sqlite3.Connection, order_id: int, status_name: str) -> None:
    cur=conn.execute(
        """
        SELECT id FROM statuses WHERE status_name = ?
        """,
        (status_name,),
    )
    row=cur.fetchone()

    if row is None:
        raise ValueError(f"Status '{status_name}' v databázi neexistuje.")
    new_status_id=row[0]

    conn.execute(
        """
        UPDATE orders SET status_id = ? WHERE id = ?
        """,
        (new_status_id,order_id,),
    )
    conn.commit()