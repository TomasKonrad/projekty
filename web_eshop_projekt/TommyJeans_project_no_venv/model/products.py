from pydantic import BaseModel, Field
from typing import Optional

class ProductCreate(BaseModel):
    product_name: str = Field(min_length=3, max_length=200, description="Název produktu")
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0, description="Cena v Kč")
    year: int = Field(default=2025, ge=1985, le=2050)

    size: str = Field(..., min_length=1)
    material: str = Field(..., min_length=1)
    type_name: str = Field(..., min_length=1, alias="type")
    category: str = Field(..., min_length=1)

class Product(ProductCreate):
    id: int

    class Config:
        from_attributes = True
        populate_by_name = True