from typing import List, Dict, Any

from fastapi import APIRouter, Request, Depends, HTTPException, Form
from starlette.responses import RedirectResponse
from starlette import status
from services.auth import User
from services.orders_manager import OrdersManagerService
from dependencies import orders_manager_service, require_shop_assistant

router = APIRouter()

@router.get("/", tags=["orders_manager_ui"])
def orders_manager_ui(
        request: Request,
        svc: OrdersManagerService = Depends(orders_manager_service),
        user: User = Depends(require_shop_assistant)
):
    if not user:
        return RedirectResponse('/login',
            status_code=status.HTTP_303_SEE_OTHER)

    all_orders: List[Dict[str, Any]] = svc.list_all_orders()
    return request.app.state.templates.TemplateResponse(
        "orders_manager.html",
        {
            "request": request,
            "orders": all_orders,
        }
    )

@router.get("/change_status", tags=["change_status_ui"])
def change_status_ui(
        request: Request,
        order_id: int,
        svc: OrdersManagerService = Depends(orders_manager_service),
        user: User = Depends(require_shop_assistant)
):
    statuses=svc.list_statuses()
    if not user:
        return RedirectResponse('/login',
            status_code=status.HTTP_303_SEE_OTHER)

    return request.app.state.templates.TemplateResponse(
        "orders_manager_change_status.html",
        {
            "request": request,
            "statuses": statuses,
            "order_id": order_id,
        }
    )

@router.post("/change_status", tags=["change_status_post"])
def change_status_post(
        request: Request,
        order_id: int = Form(...),
        status_name: str = Form(...),
        svc: OrdersManagerService = Depends(orders_manager_service),
        user: User = Depends(require_shop_assistant)
):
    if not user:
        return RedirectResponse('/login',
            status_code=status.HTTP_303_SEE_OTHER)

    try:
        svc.change_order_status(order_id, status_name)
        request.session["flash_success"]=f"Stav objednávky #{order_id} úspěšně aktualizován."
        return RedirectResponse(
            url=request.url_for("orders_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )
    except Exception as e:
        request.session["flash_error"] = f"Chyba: {str(e)}"
        return RedirectResponse(
            url=request.url_for("orders_manager_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

