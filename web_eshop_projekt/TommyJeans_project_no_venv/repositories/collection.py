# app/repositories/collection.py
from typing import List, Dict, Any
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

def list_products_men(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    rows = conn.execute("""
        SELECT pr.id,pr.product_name,pr.description,pr.price,pr.year,
        size.name AS size, mat.name AS material,type.name AS type, ct.name AS category
        FROM products pr LEFT JOIN sizes size ON pr.size_id = size.id
            LEFT JOIN materials mat ON pr.material_id = mat.id
            LEFT JOIN types type ON pr.type_id = type.id
            LEFT JOIN categories ct ON pr.category_id = ct.id
        WHERE ct.name = 'men'
        """
    ).fetchall()
    return [dict(r) for r in rows]

def list_products_woman(conn: sqlite3.Connection) -> List[Dict[str, Any]]:
    rows = conn.execute("""
        SELECT pr.id,pr.product_name,pr.description,pr.price,pr.year,
        size.name AS size,mat.name  AS material,type.name AS type,ct.name   AS category
        FROM products pr LEFT JOIN sizes size ON pr.size_id = size.id
            LEFT JOIN materials mat ON pr.material_id = mat.id
            LEFT JOIN types type ON pr.type_id = type.id
            LEFT JOIN categories ct ON pr.category_id = ct.id
        WHERE ct.name = 'woman'
        """
    ).fetchall()
    return [dict(r) for r in rows]