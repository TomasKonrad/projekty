from fastapi import APIRouter, Request, Depends, HTTPException
router=APIRouter()

@router.get('/', name="home_ui")
def home_ui(request: Request):
    return request.app.state.templates.TemplateResponse(
        "home.html",
        {"request": request},
    )