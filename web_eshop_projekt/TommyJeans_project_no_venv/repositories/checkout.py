# app/repositories/checkout.py
from datetime import datetime, timedelta
import sqlite3

# komplikovanejši funkce z hlediska semantiky
def create_order_from_cart(
        conn: sqlite3.Connection,
        user_id: int,
        address: str,
        payment_method: str
) -> int:
    # test, zda se najde košik
    try:
        cur=conn.execute(
            """
            SELECT id FROM carts WHERE user_id = ?
            """,
            (user_id,)
        )
        row=cur.fetchone()
        if not row:
            raise ValueError("Košík nebyl nalezen")
        cart_id = row[0]

        # produkty z kosiku
        cart_products=conn.execute(
            """
            SELECT cartpr.product_id,
            cartpr.quantity,
            pr.price
            FROM cart_products cartpr JOIN products pr ON cartpr.product_id=pr.id
                WHERE cartpr.cart_id=?
            """, (cart_id,)
        ).fetchall()
        if not cart_products:
            raise ValueError("Košík je prázdný")

        # reseni celkove ceny a datumu doruceni
        total_price=sum(product[1] * product[2] for product in cart_products)
        order_delivery_date= (datetime.now() + timedelta(days=3)).date()

        # hledani id statusu
        cur=conn.execute(
            """
            SELECT id FROM statuses WHERE status_name = 'Přijatá'
            """
        )
        status_row=cur.fetchone()
        if not status_row:
            #TODO zkontrolovat tuto cast funkce
            raise ValueError("Tento status v databázi neexistuje")
        else:
            id_statusu=status_row[0]

        # vytvořeni objednavky
        cur=conn.execute(
            """
            INSERT INTO orders (user_id, total_price, address, payment_method, status_id, created_at, delivery_date)
                VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?)
            """, (user_id, total_price, address, payment_method, id_statusu, order_delivery_date)
        )

        new_order_id=cur.lastrowid

        # uloženi ceny při objednani + uloženi do many to many tabulky
        ordered_products_prices=[(new_order_id, product[0], product[1], product[2]) for product in cart_products]

        conn.executemany(
            """
            INSERT INTO order_products (order_id,product_id,quantity,unit_price)
                VALUES (?,?,?,?)
            """,
            ordered_products_prices
        )

        # smazani produktu z kosiku
        conn.execute(
            """
            DELETE FROM cart_products WHERE cart_id = ?
            """,
            (cart_id,)
        )

        conn.commit()
        return new_order_id

    # když se to nepovede, vratí zmeny zpet
    except sqlite3.IntegrityError as e:
        conn.rollback()
        raise e


