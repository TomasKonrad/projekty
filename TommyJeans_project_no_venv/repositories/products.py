# app/repositories/products.py
from typing import List, Dict, Any, Optional
import sqlite3

def list_products(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    rows = conn.execute("""
        SELECT pr.id,pr.product_name,pr.description,pr.price,pr.year,
        size.name AS size, mat.name AS material,type.name AS type, ct.name AS category
        FROM products pr LEFT JOIN sizes size ON pr.size_id = size.id
            LEFT JOIN materials mat ON pr.material_id = mat.id
            LEFT JOIN types type ON pr.type_id = type.id
            LEFT JOIN categories ct ON pr.category_id = ct.id
        """
    ).fetchall()
    return [dict(r) for r in rows]

def all_products_count(conn: sqlite3.Connection) -> int:
    cur = conn.execute(
        """
        SELECT COUNT(*) FROM products
        """
    )
    return cur.fetchone()[0]

def insert_product(
        conn: sqlite3.Connection,
        product_name: str,
        price: float,
        size: str,
        material: str,
        type_name: str,
        category: str,
        year: int,
        description: Optional[str] = None,
) -> int:
    cur=conn.execute(
        """
        INSERT INTO products(product_name, description, price, year, size_id, material_id, type_id, category_id)
        VALUES (?, ?, ?, ?,
               (SELECT id FROM sizes WHERE name = ?),
               (SELECT id FROM materials WHERE name = ?),
               (SELECT id FROM types WHERE name = ?),
               (SELECT id FROM categories WHERE name = ?))
        """,
        (product_name, description, price, year, size, material, type_name, category)
    )
    conn.commit()
    return cur.lastrowid

def update_product(
        conn: sqlite3.Connection,
        product_id: int,
        product_name: str,
        price: float,
        size: str,
        material: str,
        type_name: str,
        category: str,
        year: int,
        description: Optional[str] = None,
) -> bool:
    cur = conn.execute(
        """
        UPDATE products
        SET product_name=?,description=?,price=?,year=?,
            size_id=(SELECT id FROM sizes WHERE name = ?),
            material_id=(SELECT id FROM materials WHERE name = ?),
            type_id=(SELECT id FROM types WHERE name = ?),
            category_id=(SELECT id FROM categories WHERE name = ?)
        WHERE id = ?
        """,
        (product_name, description, price, year, size, material, type_name, category,product_id)
    )
    conn.commit()
    return cur.rowcount > 0

def delete_product(conn: sqlite3.Connection, product_id:int) -> bool:
    cur=conn.execute(
        "DELETE FROM products WHERE id = ?",
        (product_id,)
    )
    conn.commit()
    return cur.rowcount > 0

# načitání seznamů atributů do formulare v product

def list_categories(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT name FROM categories ORDER BY name"
        ).fetchall()
    return [r[0] for r in rows]

def list_types(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT name FROM types ORDER BY name"
        ).fetchall()
    return [r[0] for r in rows]

def list_sizes(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT name FROM sizes ORDER BY id"
        ).fetchall()
    return [r[0] for r in rows]

def list_materials(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT name FROM materials ORDER BY name"
        ).fetchall()
    return [r[0] for r in rows]