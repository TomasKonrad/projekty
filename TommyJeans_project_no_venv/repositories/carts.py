# app/repositories/carts.py
import sqlite3
from typing import Dict, Any


def get_user_cart(
        conn: sqlite3.Connection,
        user_id: int,
) -> list[Dict[str, Any]]:
    rows = conn.execute(
        """
        SELECT pr.id as product_id,
        pr.product_name,
        pr.price,
        pr.description,
        cartpr.quantity,
        s.name as size_name,
        mat.name as material_name,
        t.name as type_name,
        (pr.price*cartpr.quantity) as quantity_price
        FROM carts c JOIN cart_products cartpr ON c.id = cartpr.cart_id
            JOIN products pr ON cartpr.product_id = pr.id
            LEFT JOIN sizes s ON pr.size_id = s.id
            LEFT JOIN materials mat ON pr.material_id = mat.id
            LEFT JOIN types t ON pr.type_id = t.id
            WHERE c.user_id = ?            
        """,
        (user_id,)
    ).fetchall()
    return [dict(row) for row in rows]


def add_product_to_cart(
        conn: sqlite3.Connection,
        user_id: int,
        product_id: int,
        quantity: int=1
) -> int:
    cur=conn.execute("SELECT id FROM carts WHERE user_id = ?", (user_id,))
    row=cur.fetchone()

    if row:
        cart_id = row[0]
    else:
        cur=conn.execute("INSERT INTO carts (user_id) VALUES (?)", (user_id,))
        cart_id = cur.lastrowid

    conn.execute(
        """
        INSERT INTO cart_products (cart_id, product_id, quantity) VALUES (?, ?, ?)
        ON CONFLICT (cart_id, product_id) DO UPDATE SET quantity = quantity + ?
        """,
        (cart_id, product_id, quantity, quantity)
    )

    conn.commit()
    return cart_id

def remove_product_from_cart(
        conn: sqlite3.Connection,
        user_id: int,
        product_id: int
) -> None:
    cur=conn.execute(
        """
        DELETE FROM cart_products WHERE product_id=?
        AND cart_id = (SELECT id FROM carts WHERE user_id = ?)
        """,
        (product_id, user_id)
    )
    print(f"Smazáno řádků: {cur.rowcount}")
    conn.commit()

def decrease_product_quantity(
        conn: sqlite3.Connection,
        user_id: int,
        product_id: int,
) -> None:
    cur=conn.execute("""
        SELECT quantity FROM cart_products 
        WHERE product_id = ? AND cart_id = 
        (SELECT id FROM carts WHERE user_id = ?)
        """,
        (product_id, user_id),
    )
    row=cur.fetchone()

    if not row:
        return

    current_quantity = row[0]

    if current_quantity > 1:
        conn.execute(
            """
            UPDATE cart_products 
            SET quantity = quantity - 1 
            WHERE product_id = ? 
            AND cart_id = (SELECT id FROM carts WHERE user_id = ?)
            """, (product_id, user_id)
        )
        conn.commit()
    else:
        remove_product_from_cart(conn, user_id, product_id)
