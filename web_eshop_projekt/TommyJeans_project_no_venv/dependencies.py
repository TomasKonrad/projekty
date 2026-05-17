import sqlite3
from typing import Iterator, Optional
from fastapi import Depends, HTTPException, Request, status

from database.database import open_connection
from services.auth import AuthService, User
from services.carts import CartsService
from services.checkout import CheckoutService
from services.orders import OrdersService
from services.session import session_store, SESSION_COOKIE_NAME
from services.collection import CollectionService
from services.products import ProductsService
from services.orders_manager import OrdersManagerService
from services.users_manager import UsersManagerService


def get_conn() -> Iterator[sqlite3.Connection]:
    with open_connection() as conn:
        yield conn

def collection_service(conn: sqlite3.Connection = Depends(get_conn)) -> CollectionService:
    return CollectionService(conn)

def products_service(conn: sqlite3.Connection = Depends(get_conn)) -> ProductsService:
    return ProductsService(conn)

def cart_service(conn: sqlite3.Connection = Depends(get_conn)) -> CartsService:
    return CartsService(conn)

def checkout_service(conn: sqlite3.Connection = Depends(get_conn)) -> CheckoutService:
    return CheckoutService(conn)

def orders_service(conn: sqlite3.Connection = Depends(get_conn)) -> OrdersService:
    return OrdersService(conn)

def orders_manager_service(conn: sqlite3.Connection = Depends(get_conn)) -> OrdersManagerService:
    return OrdersManagerService(conn)

def users_manager_service(conn: sqlite3.Connection = Depends(get_conn)) -> UsersManagerService:
    return UsersManagerService(conn)

def auth_service(conn: sqlite3.Connection = Depends(get_conn)) -> AuthService:
    return AuthService(conn)

def get_current_user(request: Request) -> Optional[User]:
    session_id = request.cookies.get(SESSION_COOKIE_NAME)
    return session_store.get_user(session_id)

def require_user(user: Optional[User] = Depends(get_current_user)) -> User:
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Login required")
    return user

def require_shop_assistant(user: User = Depends(require_user)) -> User:
    if user.role != "shop_assistant":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Shop_assistant access required")
    return user

def require_admin(user: User = Depends(require_user)) -> User:
    if user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return user
