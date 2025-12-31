# app/pages/users_manager.py

from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Request, Depends, Form, HTTPException
from starlette import status
from starlette.responses import RedirectResponse
from services.auth import User
from services.users_manager import UsersManagerService

# pro účely testování
from dependencies import users_manager_service, require_admin

router=APIRouter()

@router.get('/', name="users_manager_ui")
def users_manager_ui(
        request: Request,
        svc: UsersManagerService = Depends(users_manager_service),
        user: User = Depends(require_admin),
):
    if not user:
        return RedirectResponse('/login',
                                status_code=status.HTTP_303_SEE_OTHER)


    list_users: List[Dict[str, Any]] = svc.list_all_users()
    return request.app.state.templates.TemplateResponse(
        "users_manager.html",
        {"request": request,
         "list_users": list_users,
         "user": user
         },
    )

@router.get('/change_user_role', name="change_user_role_ui")
def change_user_role_ui(
        request: Request,
        user_id: int,
        user: User = Depends(require_admin),
):
    if not user:
        return RedirectResponse('/login',
            status_code=status.HTTP_303_SEE_OTHER)

    return request.app.state.templates.TemplateResponse(
        "users_manager_change_role.html",
        {
            "request": request,
            "user_id": user_id,
        }
    )

@router.post('/change_user_role', name="change_user_role_post")
def change_user_role_post(
        request: Request,
        user_id: int = Form(...),
        role: str = Form(...),
        svc: UsersManagerService = Depends(users_manager_service),
        user: User = Depends(require_admin),
):
    if not user:
        return RedirectResponse('/login',
                                status_code=status.HTTP_303_SEE_OTHER)

    allowed_roles = ["admin", "shop_assistant", "user"]
    if role not in allowed_roles:
        request.session["flash_error"] = f"Neplatná role: '{role}'."
        return RedirectResponse(
            url=request.url_for("users_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    try:
        svc.change_user_role(user_id, role)
        request.session["flash_success"] = f"Role uživatele #{user_id} byla aktualizována na {role}."
        return RedirectResponse(
            url=request.url_for("users_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )
    except Exception as e:
        request.session["flash_error"] = f"Chyba: {str(e)}"
        return RedirectResponse(
            url=request.url_for("users_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    #TODO přidat mazání uživatele z databáze
@router.post('/', name="users_manager_ui_delete_user")
def delete_user(
        request: Request,
        user_id: int = Form(...),
        user: User = Depends(require_admin),
        svc: UsersManagerService = Depends(users_manager_service),
):
    if not user:
        return RedirectResponse('/login',
                                status_code=status.HTTP_303_SEE_OTHER)

    try:
        svc.delete_user(user_id=user_id)
        request.session["flash_success"] = "Uživatel byl odstraněn."
        return RedirectResponse(
            url=request.url_for("users_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )
    except Exception as e:
        request.session["flash_error"] = f"Chyba: {str(e)}"


