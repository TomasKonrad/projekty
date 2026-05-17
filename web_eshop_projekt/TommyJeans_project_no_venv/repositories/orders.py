#app/repositories/orders.py
import sqlite3
from typing import List, Dict, Any, Optional


def list_user_orders(conn: sqlite3.Connection,
                     user_id: int
                     ) -> List[Dict[str, Any]]:
    rows = conn.execute(
        """
        SELECT ord.id, ord.created_at, ord.total_price, s.status_name
        FROM orders ord JOIN statuses s ON ord.status_id = s.id
        WHERE ord.user_id = ?
        ORDER BY ord.created_at desc
        """,
        (user_id,),
    ).fetchall()
    return [dict(r) for r in rows]

def get_order_detail(
        conn: sqlite3.Connection,
        order_id: int,
        user_id: int
) -> Optional[Dict[str, Any]]:
    rows = conn.execute(
        """
        SELECT ord.id, ord.created_at, ord.total_price,ord.address,ord.payment_method, ord.delivery_date,s.status_name
        FROM orders ord JOIN statuses s ON ord.status_id = s.id
        WHERE ord.id=? AND ord.user_id=?
        """,
        (order_id,user_id,),
    ).fetchone()

    if rows is None:
        return None

    return dict(rows)

def get_order_products(
        conn: sqlite3.Connection,
        order_id: int
) -> list[Dict[str, Any]]:
    rows = conn.execute(
    """
        SELECT ordpr.product_id, pr.product_name, ordpr.quantity, ordpr.unit_price,(ordpr.quantity*ordpr.unit_price) as subtotal
        FROM order_products ordpr JOIN products pr ON ordpr.product_id = pr.id
        WHERE ordpr.order_id=?
        ORDER BY ordpr.order_id
        """,
        (order_id,),
    ).fetchall()

    return [dict(row) for row in rows]

def cancel_order(
        conn: sqlite3.Connection,
        order_id: int,
        user_id: int
) -> bool:
    cur=conn.execute(
    """
    UPDATE orders 
    SET status_id = (SELECT id FROM statuses WHERE status_name = 'Zrušená')
    WHERE id = ? AND user_id = ? AND status_id = (
        SELECT id FROM statuses WHERE status_name = 'Přijatá'
        );

    """,
    (order_id,user_id,),
    )
    conn.commit()
    return cur.rowcount > 0