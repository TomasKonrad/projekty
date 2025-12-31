# app/pages/products.py
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Request, Depends, Form, HTTPException
from starlette import status
from starlette.responses import RedirectResponse
from services.auth import User
from services.products import ProductsService

# pro účely testování
from dependencies import products_service, require_shop_assistant

router=APIRouter()

@router.get('/', name="products_ui")
def products_ui(request: Request,
    svc: ProductsService = Depends(products_service),
    user: User = Depends(require_shop_assistant),
):
    products: List[Dict[str, Any]] = svc.list_products()
    return request.app.state.templates.TemplateResponse(
        "products.html",
        {"request": request,
         "products": products,
         "user": user
         },
    )

@router.get('/new', name="create_product_ui")
def create_product_ui(
        request: Request,
        svc: ProductsService = Depends(products_service),
        user: User = Depends(require_shop_assistant)
):
    options=svc.get_product_options()

    return request.app.state.templates.TemplateResponse(
        "create_product.html",
        {"request": request,
         "options": options,
         "form": {"product_name": "",
                  "price": "",
                  "size": "",
                  "material": "",
                  "type_name": "",
                  "category": "",
                  "year": "",
                  "description": ""},
         "user": user
         },
    )


@router.post("/new", name="create_product_ui_post")
def create_product_post(
        request: Request,
        product_name: str = Form(...),
        price: float = Form(...),
        size: str = Form(...),
        material: str = Form(...),
        type_name: str = Form(...),
        category: str = Form(...),
        year: int = Form(...),
        description: Optional[str]=Form(None),
        svc: ProductsService = Depends(products_service),
        user: User = Depends(require_shop_assistant),
):
    errors: Dict[str, str] = {}

    if not product_name or len(product_name.strip()) < 3:
        errors["product_name"] = "Název musí mít alespoň tři znaky"

    if price <=0:
        errors["price"] = "Cena nesmí být nulová"

    if len(size.strip())>3 :
        errors["size"] = "Velikost může mít max tři znaky"

    if year < 1985 or year > 2050:
        errors["year"] = "Rok musí být mezi 1985 a 2050."

    if errors:
        options = svc.get_product_options()
        return request.app.state.templates.TemplateResponse(
            "create_product.html",
            {
                "request": request,
                "errors": errors,
                "options": options,
                "form": {
                    "product_name": product_name,
                    "price": price,
                    "description": description,
                    "size": size,
                    "material": material,
                    "type_name": type_name,
                    "category": category,
                    "year": year
                },
                "user": user
            },
        )

    svc.create_product(
        product_name=product_name.strip(),
        price=price,
        size=size,
        material=material,
        type_name=type_name,
        category=category,
        year=year,
        description=description
    )

    request.session["flash_success"] = "Produkt byl úspěšně přidán."

    return RedirectResponse(
        url=request.url_for("products_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )

@router.get('/update', name="update_product_ui")
def update_product_ui(
        request: Request,
        product_id: int,
        svc: ProductsService = Depends(products_service),
        user: User = Depends(require_shop_assistant)
):
    options=svc.get_product_options()

    return request.app.state.templates.TemplateResponse(
        "update_product.html",
        {"request": request,
         "options": options,
         "form": {"product_id": product_id if product_id else "",
                  "product_name": "",
                  "price": "",
                  "size": "",
                  "material": "",
                  "type_name": "",
                  "category": "",
                  "year": "",
                  "description": ""
                 },
         "user": user
         },
    )

@router.post("/update", name="update_product_ui_put")
def update_product_put(
        request: Request,
        product_id: int = Form(...),
        product_name: str = Form(...),
        price: float = Form(...),
        size: str = Form(...),
        material: str = Form(...),
        type_name: str = Form(...),
        category: str = Form(...),
        year: int = Form(...),
        description: Optional[str]=Form(None),
        svc: ProductsService = Depends(products_service),
        user: User = Depends(require_shop_assistant),
):
    errors: Dict[str, str] = {}
    if not product_name or len(product_name.strip()) < 3:
        errors["product_name"]="Název musí mít alespoň tři znaky"

    if price <=0:
        errors["price"]= "Cena musí být kladná"

    if len(size.strip()) > 3:
        errors["size"] = "Velikost může mít max tři znaky"

    if year < 1985 or year > 2050:
        errors["year"] = "Rok musí být mezi 1985 a 2050."

    if errors:
        options = svc.get_product_options()
        return request.app.state.templates.TemplateResponse(
            "update_product.html",
            {
                "request": request,
                "errors": errors,
                "options": options,
                "form": {
                    "product_id": product_id,
                    "product_name": product_name,
                    "price": price,
                    "description": description,
                    "size": size,
                    "material": material,
                    "type_name": type_name,
                    "category": category,
                    "year": year
                },
                "user": user
            },
        )

    try:
        svc.update_product(
            product_id=product_id,
            product_name=product_name.strip(),
            price=price,
            size=size,
            material=material,
            type_name=type_name,
            category=category,
            year=year,
            description=description
        )

        return request.app.state.templates.TemplateResponse(
            "product_update_success.html",
            {
                "request": request,
                "product_id": product_id,
                "product_name": product_name,
                "user": user
            }
        )

    except HTTPException as e:
        options = svc.get_product_options()
        return request.app.state.templates.TemplateResponse(
            "update_product.html",
            {"request": request,
             "errors": e,
             "user": user,
             "options": options,
             "form":{
                 "product_id": product_id,
                 "product_name": product_name,
                 "price": price,
                 "description": description,
                 "size": size,
                 "material": material,
                 "type_name": type_name,
                 "category": category,
                 "year": year
                    }
             }
        )

@router.post("/", name="products_ui_delete")
def delete_product(
        request: Request,
        product_id: int = Form(...),
        svc: ProductsService = Depends(products_service),
        user: User = Depends(require_shop_assistant),
):
    if not user:
        return RedirectResponse(
            url=request.url_for("login_ui"),
            status_code=status.HTTP_303_SEE_OTHER
        )

    svc.delete_product(
        product_id=product_id
    )

    request.session["flash_success"] = "Produkt byl odstraněn."

    return RedirectResponse(
        url=request.url_for("products_ui"),
        status_code=status.HTTP_303_SEE_OTHER
    )