from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from starlette import status
from dependencies import auth_service
from services.auth import AuthService
from services.session import SESSION_COOKIE_NAME, session_store

router = APIRouter()

@router.get("/register", name="register_ui")
async def register_ui(request: Request):
    return request.app.state.templates.TemplateResponse(
        "register.html",
        {"request": request, "error": None},
    )

@router.post("/register", name="register_post")
async def register_post(
    request: Request,
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    svc: AuthService = Depends(auth_service),
):
    try:
        svc.register_user(username, email, password)
        response=RedirectResponse(
            url=request.url_for("login_ui"),
            status_code = status.HTTP_303_SEE_OTHER
        )
        return response

    except ValueError as e:
        return request.app.state.templates.TemplateResponse(
            "register.html",
            {"request": request, "error": str(e)},
        )

@router.get("/login", name="login_ui")
async def login_ui(request: Request):
    return request.app.state.templates.TemplateResponse(
        "login.html",
        {"request": request, "error": None},
    )


@router.post("/login", name="login_post")
async def login_post(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    svc: AuthService = Depends(auth_service),
):
    user = svc.authenticate(username, password)
    if not user:
        return request.app.state.templates.TemplateResponse(
            "login.html",
            {
                "request": request,
                "error": "Invalid username or password",
            },
            status_code=status.HTTP_401_UNAUTHORIZED,
        )

    session_id = session_store.create_session(user)
    response = RedirectResponse(
        url=request.query_params.get("next") or request.url_for("dashboard_ui"),
        status_code=status.HTTP_303_SEE_OTHER,
    )
    response.set_cookie(SESSION_COOKIE_NAME, session_id, httponly=True)
    return response


@router.post("/logout", name="logout")
async def logout(request: Request):
    session_id = request.cookies.get(SESSION_COOKIE_NAME)
    session_store.delete_session(session_id)
    response = RedirectResponse(
        url=request.url_for("dashboard_ui"),
        status_code=status.HTTP_303_SEE_OTHER,
    )
    response.delete_cookie(SESSION_COOKIE_NAME)
    return response

