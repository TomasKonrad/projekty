# app/pages/collection.py
from typing import List, Dict, Any
from fastapi import APIRouter, Request, Depends

from dependencies import collection_service
from services.collection import CollectionService

router=APIRouter()

@router.get('/', name="collection_ui")
async def collection_ui(
        request: Request,
        svc: CollectionService = Depends(collection_service)
):
    products: List[Dict[str, Any]] = svc.list_products()
    return request.app.state.templates.TemplateResponse(
        "collection.html",
        {"request": request, "products": products},
    )

@router.get('/men', name="collection_men_ui")
async def collection_men_ui(
        request: Request,
        svc: CollectionService = Depends(collection_service)
):
    products: List[Dict[str, Any]] = svc.list_products_men()
    return request.app.state.templates.TemplateResponse(
        "collection_men.html",
        {"request": request, "products": products},
    )

@router.get('/woman', name="collection_woman_ui")
async def collection_woman_ui(
        request: Request,
        svc: CollectionService = Depends(collection_service)
):
    products: List[Dict[str, Any]] = svc.list_products_woman()
    return request.app.state.templates.TemplateResponse(
        "collection_woman.html",
        {"request": request, "products": products},
    )


