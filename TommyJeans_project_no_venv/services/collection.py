#app/services/collection.py
from typing import List, Dict, Any
import sqlite3
from repositories.collection import list_products as repo_list_products
from repositories.collection import list_products_men as repo_list_products_men
from repositories.collection import list_products_woman as repo_list_products_woman

class CollectionService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def list_products(self) -> List[Dict[str, Any]]:
        return repo_list_products(self.conn)

    def list_products_men(self) -> List[Dict[str, Any]]:
        return repo_list_products_men(self.conn)

    def list_products_woman(self) -> List[Dict[str, Any]]:
        return repo_list_products_woman(self.conn)
