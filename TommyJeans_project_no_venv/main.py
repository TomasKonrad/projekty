# app/main.py
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from pages.dashboard import router as dashboard_router  # ← DŮLEŽITÉ: přímý import modulu
from pages.collection import router as collection_router
from pages.products import router as products_router
from pages.carts import router as carts_router
from pages.checkout import router as checkout_router
from pages.orders import router as orders_router
from pages.orders_manager import router as ordersmanager_router
from pages.users_manager import router as users_manager_router
from pages.auth import router as auth_router
from pages.home import router as home_router
from dependencies import auth_service, get_current_user
from services.auth import AuthService

def create_app() -> FastAPI:
    app = FastAPI(title="Mini FastAPI")

    app.mount("/static", StaticFiles(directory="static"), name="static")
    app.state.templates = Jinja2Templates(directory="templates")

    app.include_router(home_router, prefix="", tags=["homepage"])
    app.include_router(dashboard_router, prefix="/dashboard", tags=["dashboard"])
    app.include_router(collection_router, prefix="/collection", tags=["collection"])
    app.include_router(products_router, prefix="/products", tags=["products"])
    app.include_router(carts_router, prefix="/carts", tags=["carts"])
    app.include_router(checkout_router, prefix="/checkout", tags=["checkout"])
    app.include_router(orders_router, prefix="/orders", tags=["order"])
    app.include_router(ordersmanager_router, prefix="/orders_manager", tags=["orders_manager"])
    app.include_router(users_manager_router, prefix="/users_manager", tags=["users_manager"])
    app.include_router(auth_router, prefix="", tags=["auth"])


    # DEBUG: vypiš zaregistrované cesty
    print("=== ROUTES ===")
    for r in app.routes:
        try:
            print(getattr(r, "methods", ""), getattr(r, "path", ""))
        except Exception:
            pass

    # Pokud používáš override přes třídu, nech, jinak ho klidně vyhoď
    # app.dependency_overrides[ItemsService] = items_service
    app.dependency_overrides[AuthService] = auth_service

    app.add_middleware(SessionMiddleware, secret_key="dev-secret")

    app.state.templates.env.globals.update(get_user=lambda request: getattr(request.state, "user", None))

    @app.middleware("http")
    async def inject_user(request: Request, call_next):
        request.state.user = get_current_user(request)
        response = await call_next(request)
        return response

    return app

app = create_app()
