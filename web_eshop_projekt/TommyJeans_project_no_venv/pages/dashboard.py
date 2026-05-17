from fastapi import APIRouter, Depends, Request
from starlette.responses import RedirectResponse
from starlette import status
from services.auth import User
from dependencies import get_current_user, orders_manager_service, users_manager_service, products_service
from services.orders import OrdersService
from services.orders_manager import OrdersManagerService
from services.products import ProductsService
from services.users_manager import UsersManagerService

router = APIRouter()


@router.get("/", name="dashboard_ui")
async def dashboard_ui(request: Request,
                       user: User | None = Depends(get_current_user),
                       users_svc: UsersManagerService = Depends(users_manager_service),
                       products_svc: ProductsService = Depends(products_service),
                       order_svc: OrdersManagerService = Depends(orders_manager_service)
):
    allowed_roles = ["shop_assistant", "admin"]
    if not user or user.role not in allowed_roles:
        return RedirectResponse(
            url="/login",
            status_code=status.HTTP_303_SEE_OTHER
        )

    users_count=users_svc.all_user_count()
    products_count=products_svc.all_products_count()
    orders_count=order_svc.all_orders_count()

    return request.app.state.templates.TemplateResponse(
        "dashboard.html",
        {"request": request,
         "user": user,
         "total_users": users_count,
         "total_orders": orders_count,
         "total_products": products_count,
         },
    )


