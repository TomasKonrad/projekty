import sqlite3
from repositories.carts import add_product_to_cart as repo_add_to_cart
from repositories.carts import get_user_cart as repo_get_user_cart
from repositories.carts import remove_product_from_cart as repo_remove_product_from_cart
from repositories.carts import decrease_product_quantity as repo_decrease_product_quantity
class CartsService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def get_user_carts(self, user_id: int):
        products=repo_get_user_cart(self.conn, user_id)
        total_cart_value=sum(product["quantity_price"] for product in products)
        return {
            "products": products,
            "total_cart_value": total_cart_value,
        }

    def add_product_to_cart(self, user_id: int, product_id: int, quantity: int=1) -> int:
        #TODO aktualně zbytečné, když default hodnota=1
        if quantity <= 0:
            raise ValueError("Quantity must be greater than 0")
        return repo_add_to_cart(
            conn=self.conn,
            user_id=user_id,
            product_id=product_id,
            quantity=quantity
        )

    def decrease_product_quantity(self, user_id: int, product_id: int)->None:
        repo_decrease_product_quantity(conn=self.conn,
                                       user_id=user_id,
                                       product_id=product_id
                                       )

    def remove_product_from_cart(self, user_id: int, product_id: int):
        return repo_remove_product_from_cart(self.conn, user_id, product_id)