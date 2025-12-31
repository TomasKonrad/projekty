# app/pages/checkout.py
from fastapi import APIRouter, Request, Form, Depends
from starlette.responses import RedirectResponse

from dependencies import get_current_user, checkout_service, cart_service
from starlette import status

from services.carts import CartsService
from services.checkout import CheckoutService

router=APIRouter()

@router.get("/", tags=["checkout_ui"])
def checkout_ui(
        request: Request,
        user=Depends(get_current_user),
        cart_svc: CartsService = Depends(cart_service)
):
    cart_products= cart_svc.get_user_carts(user.id)
    if not cart_products["products"]:
        request.session["flash_error"] = ("Váš košík je prázdný.")
        return RedirectResponse(
        url=request.url_for("carts_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )
    return request.app.state.templates.TemplateResponse(
        "checkout.html",
        {
            "request": request,
            "user": user,
            "products": cart_products["products"],
            "total_price": cart_products["total_cart_value"]
        }
    )



@router.post('/create_order',name="checkout_post")
def create_order_from_cart(
        request: Request,
        address: str = Form(...),
        payment_method: str = Form(...),
        user = Depends(get_current_user),
        svc: CheckoutService = Depends(checkout_service),
):
    if not address or not address.strip():
        request.session["flash_error"] = "Adresa nesmí být prázdná."
        return RedirectResponse(
            url=request.url_for("checkout_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    try:
        new_order_id=svc.create_order_from_cart(
            user_id=user.id,
            address=address,
            payment_method=payment_method,
        )
        return RedirectResponse(
            url=request.url_for("order_success", order_id=new_order_id),
            status_code=status.HTTP_303_SEE_OTHER
        )
    except ValueError as e:
        request.session["flash_error"] = f"Chyba při vytváření objednávky: {str(e)}"
        return RedirectResponse(
            url=request.url_for("carts_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

