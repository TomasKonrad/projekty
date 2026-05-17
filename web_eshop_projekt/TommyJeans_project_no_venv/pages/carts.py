# app/pages/carts.py
from typing import Dict

from fastapi import APIRouter, Request, Depends, Form
from starlette import status
from starlette.responses import RedirectResponse

from dependencies import cart_service,get_current_user
from services.auth import User
from services.carts import CartsService

router=APIRouter()

@router.get('/', name='carts_ui')
def get_user_cart(
    request: Request,
    svc: CartsService = Depends(cart_service),
    user: User = Depends(get_current_user)
):
    if not user:
        return RedirectResponse('/login', status_code=status.HTTP_303_SEE_OTHER)

    cart=svc.get_user_carts(
        user_id=user.id,
    )

    return request.app.state.templates.TemplateResponse(
        'carts.html',
        {
            'request': request,
            "products": cart["products"],
            "total_price": cart["total_cart_value"],
            "user": user
        },
    )

@router.post('/add',name="carts_post")
def add_product_to_cart(
        request: Request,
        product_id: int=Form(...),
        svc: CartsService = Depends(cart_service),
        user: User = Depends(get_current_user),
):
    errors: Dict[str, str] = {}
    if product_id <=0:
        errors['productId'] = "Neplatné produkt id"

    if errors:
        return RedirectResponse(
            url=request.url_for("collection_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    svc.add_product_to_cart(
        user_id=user.id,
        product_id=product_id,
    )

    request.session["flash_success"] = "Produkt byl přidán do košíku."
    return RedirectResponse(
        url=request.url_for("collection_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )

@router.post('/decrease',name="carts_decrease_post")
def decrease_product_quantity(
        request: Request,
        product_id: int = Form(...),
        svc: CartsService = Depends(cart_service),
        user: User = Depends(get_current_user),
):
    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    svc.decrease_product_quantity(
        user_id=user.id,
        product_id=product_id
    )

    return RedirectResponse(
        url=request.url_for("carts_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )

@router.post('/delete',name="carts_delete")
def remove_product_from_cart(
        request: Request,
        product_id: int=Form(...),
        svc: CartsService = Depends(cart_service),
        user: User = Depends(get_current_user),
):
    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    svc.remove_product_from_cart(
        user_id=user.id,
        product_id=product_id,
    )

    request.session["flash_success"] = "Položka byla odstraněna z košíku."

    return RedirectResponse(
        url=request.url_for("carts_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )