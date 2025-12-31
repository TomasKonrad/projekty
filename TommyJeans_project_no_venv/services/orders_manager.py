#app/services/orders_manager.py
from typing import List, Dict, Any
import sqlite3

from repositories.orders_manager import list_all_orders as repo_list_all_orders
from repositories.orders_manager import list_statuses as repo_list_statuses
from repositories.orders_manager import change_order_status as repo_change_order_status
from repositories.orders_manager import all_orders_count as repo_all_orders_count
class OrdersManagerService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def list_all_orders(self) -> List[Dict[str, Any]]:
        return repo_list_all_orders(self.conn)

    def all_orders_count(self)->int:
        return repo_all_orders_count(self.conn)

    def list_statuses(self) -> List[str]:
        return repo_list_statuses(self.conn)

    # problém: vraci jen statuses a ne statusy ze sloupce
    # def list_statuses(self) -> Dict[str, List[str]]:
    #     return {
    #             "statuses": repo_list_statuses(self.conn)
    #             }

    def change_order_status(self, order_id: int, status_name: str) -> None:
        return repo_change_order_status(self.conn, order_id, status_name)
