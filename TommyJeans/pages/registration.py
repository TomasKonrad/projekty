from fastapi import APIRouter, Request, Depends, HTTPException
router=APIRouter()

@router.get('/', name="registration_ui")
def registration_ui(request: Request):
    return request.app.state.templates.TemplateResponse(
        "registration.html",
        {"request": request},
    )