#app/services/products.py
from typing import List, Dict, Any, Optional
import sqlite3

from fastapi import HTTPException
from starlette import status

from repositories.products import list_products as repo_list_products
from repositories.products import insert_product as repo_insert_product
from repositories.products import update_product as repo_update_product
from repositories.products import delete_product as repo_delete_product
from repositories.products import list_categories as repo_list_categories
from repositories.products import list_types as repo_list_types
from repositories.products import list_sizes as repo_list_sizes
from repositories.products import list_materials as repo_list_materials
from repositories.products import all_products_count as repo_all_products_count

class ProductsService:
    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def list_products(self) -> List[Dict[str, Any]]:
        return repo_list_products(self.conn)

    def all_products_count(self) -> int:
        return repo_all_products_count(self.conn)

    def create_product(self, product_name: str, price: float, size: str, material: str, type_name: str, category: str, year: int, description: Optional[str]=None)->int:
        return repo_insert_product(self.conn,product_name=product_name,price=price,size=size,material=material,type_name=type_name, category=category,year=year,description=description)

    def update_product(self, product_id: int, product_name: str, price: float, size: str, material: str, type_name: str, category: str, year: int, description: Optional[str]=None) -> None:
        updated=repo_update_product(
            self.conn,
            product_id=product_id,
            product_name=product_name,
            price=price,
            size=size,
            material=material,
            type_name=type_name,
            category=category,
            year=year,
            description=description
        )

        if not updated:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Product s ID {product_id} nenalezen.")

    def delete_product(self, product_id: int)->None:
        deleted=repo_delete_product(self.conn,product_id=product_id)
        if not deleted:
            raise HTTPException(status.HTTP_404_NOT_FOUND, detail=f"Product s ID {product_id} nenalezen.")

    def get_product_options(self)->Dict[str, List[str]]:
        return {
            "categories": repo_list_categories(self.conn),
            "types": repo_list_types(self.conn),
            "sizes": repo_list_sizes(self.conn),
            "materials": repo_list_materials(self.conn),
        }