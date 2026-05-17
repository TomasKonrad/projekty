#app/services/orders.py
from typing import List, Dict, Any, Optional
import sqlite3

from repositories.orders import list_user_orders as repo_list_user_orders
from repositories.orders import get_order_detail as repo_get_order_detail
from repositories.orders import get_order_products as repo_get_order_products
from repositories.orders import cancel_order as repo_cancel_order
class OrdersService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def list_user_orders(self, user_id) -> List[Dict[str, Any]]:
        return repo_list_user_orders(self.conn, user_id)

    def get_order_details(self, order_id: int, user_id: int) -> Optional[dict[str, Any]]:
        order_details = repo_get_order_detail(self.conn, order_id, user_id)
        if order_details is None:
            return None

        order_details['products']=repo_get_order_products(self.conn, order_id)
        return order_details

    def cancel_order(self, order_id: int, user_id: int) -> bool:
        success=repo_cancel_order(self.conn, order_id, user_id)
        return success