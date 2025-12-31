from typing import List, Dict, Any

from fastapi import APIRouter, Request, Depends, HTTPException
from starlette.responses import RedirectResponse
from starlette import status
from services.auth import User
from services.orders import OrdersService
from dependencies import orders_service, get_current_user

router = APIRouter()

@router.get("/success/{order_id}", tags=["order_success"])
def order_success(
        request: Request,
        order_id: int):
    return request.app.state.templates.TemplateResponse(
        "order_success.html",
        {
            "request": request,
            "order_id": order_id
        }
    )

@router.get("/", tags=["orders_ui"])
def orders_ui(
        request: Request,
        svc: OrdersService = Depends(orders_service),
        user: User = Depends(get_current_user)
):
    if not user:
        return RedirectResponse('/login',
            status_code=status.HTTP_303_SEE_OTHER)

    user_orders: List[Dict[str, Any]] = svc.list_user_orders(user_id=user.id)
    return request.app.state.templates.TemplateResponse(
        "orders.html",
        {
            "request": request,
            "orders": user_orders,
        }
    )

@router.get("/{order_id}", tags=["order_detail_ui"])
def orders_detail_ui(
        request: Request,
        order_id: int,
        svc: OrdersService = Depends(orders_service),
        user: User = Depends(get_current_user)
):
    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    order=svc.get_order_details(order_id=order_id, user_id=user.id)

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
        )

    return request.app.state.templates.TemplateResponse(
        "order_details.html",
        {
            "request": request,
            "order": order,
        }
    )

@router.post("/{order_id}/cancelled", tags=["cancel_order"])
def cancel_order(
        request: Request,
        order_id: int,
        svc: OrdersService = Depends(orders_service),
        user: User = Depends(get_current_user)
):
    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    success=svc.cancel_order(order_id=order_id, user_id=user.id)
    if success:
        return request.app.state.templates.TemplateResponse(
            "order_cancelled.html",
            {"request": request, "order_id": order_id}
        )
    else:
        raise HTTPException(status_code=400, detail="Objednávku již nelze zrušit")
