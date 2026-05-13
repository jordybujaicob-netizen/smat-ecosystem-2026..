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

class LoginRequest(BaseModel):
    username: str
    password: str

class Estacion(BaseModel):
    id: int | None = None
    nombre: str
    ubicacion: str
    valor: int = 0

db_estaciones = [
    {"id": 1, "nombre": "Estacion norte", "ubicacion": "norte", "valor": 8},
    {"id": 2, "nombre": "Fisi-Test", "ubicacion": "Sistemas", "valor": 69}
]

@app.post("/login")
async def login(data: LoginRequest):
    if data.username == "admin" and data.password == "admin":
        return {"access_token": "token123", "token_type": "bearer"}
    raise HTTPException(status_code=401)

@app.get("/estaciones/", response_model=List[Estacion])
async def get_estaciones():
    return db_estaciones

@app.post("/estaciones/", response_model=Estacion)
async def create_estacion(est: Estacion):
    nueva = est.dict()
    nueva["id"] = len(db_estaciones) + 1
    if nueva["valor"] == 0: 
        import random
        nueva["valor"] = random.randint(1, 100)
    db_estaciones.append(nueva)
    return nueva

@app.delete("/estaciones/{id}")
async def delete_estacion(id: int):
    global db_estaciones
    db_estaciones = [e for e in db_estaciones if e["id"] != id]
    return {"ok": True}