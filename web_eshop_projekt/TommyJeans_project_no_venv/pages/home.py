from fastapi import APIRouter, Depends, Request
from starlette.responses import RedirectResponse
from starlette import status

router = APIRouter()


@router.get("/", name="home_ui")
async def home_ui(request: Request,):
    return request.app.state.templates.TemplateResponse(
        "home.html",
        {"request": request},
    )