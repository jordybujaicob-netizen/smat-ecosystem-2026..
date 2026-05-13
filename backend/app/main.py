from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Estacion(BaseModel):
    id: int | None = None
    nombre: str
    ubicacion: str
    valor: int = 0

db_estaciones = [
    {"id": 1, "nombre": "Estacion Norte", "ubicacion": "Norte", "valor": 8},
    {"id": 2, "nombre": "Fisi-Test", "ubicacion": "Sistemas", "valor": 69}
]

@app.get("/estaciones/", response_model=List[Estacion])
async def get_estaciones():
    return db_estaciones

@app.post("/estaciones/", response_model=Estacion)
async def create_estacion(est: Estacion):
    nueva = est.dict()
    nueva["id"] = len(db_estaciones) + 1
    db_estaciones.append(nueva)
    return nueva

# --- ESTO ES LO QUE FALTA PARA GUARDAR CAMBIOS ---
@app.put("/estaciones/{id}", response_model=Estacion)
async def update_estacion(id: int, est: Estacion):
    for i, e in enumerate(db_estaciones):
        if e["id"] == id:
            db_estaciones[i] = est.dict()
            db_estaciones[i]["id"] = id # Asegurar que el ID no cambie
            return db_estaciones[i]
    raise HTTPException(status_code=404, detail="No encontrada")

@app.delete("/estaciones/{id}")
async def delete_estacion(id: int):
    global db_estaciones
    db_estaciones = [e for e in db_estaciones if e["id"] != id]
    return {"ok": True}