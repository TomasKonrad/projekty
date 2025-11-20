# main.py
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates
# routers
from pages.home import router as home_router
from pages.login import router as login_router
from pages.registration import router as registration_router

def create_app() -> FastAPI:
    app=FastAPI(tittle="FastAPI - projektTommyJeans")

    app.mount("/static", StaticFiles(directory="static"), name="static")
    app.state.templates = Jinja2Templates(directory="templates")

    app.include_router(home_router, prefix="/home", tags=["home"])
    app.include_router(login_router, prefix="/login", tags=["login"])
    app.include_router(registration_router, prefix="/registration", tags=["registration"])

    print("=== ROUTES ===")
    for r in app.routes:
        try:
            print(getattr(r, "methods", ""), getattr(r, "path", ""))
        except Exception:
            pass

    return app

app = create_app()