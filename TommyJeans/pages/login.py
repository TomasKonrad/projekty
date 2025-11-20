from fastapi import APIRouter, Request, Depends, HTTPException
router=APIRouter()

@router.get('/', name="login_ui")
def login_ui(request: Request):
    return request.app.state.templates.TemplateResponse(
        "login.html",
        {"request": request},
    )