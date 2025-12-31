import sqlite3
from repositories.checkout import create_order_from_cart as repo_create_order_from_cart

class CheckoutService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def create_order_from_cart(self, user_id: int, address: str, payment_method: str) -> int:
        #TODO možná by se tu hodily if podmínky pro ověření
        order_id=repo_create_order_from_cart(
            self.conn,
            user_id=user_id,
            address=address,
            payment_method=payment_method,
        )
        return order_id

