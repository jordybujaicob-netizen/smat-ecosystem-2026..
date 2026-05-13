from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class Estacion(BaseModel):
    id: Optional[int] = None
    nombre: str
    ubicacion: str

# Base de datos temporal en memoria
db_estaciones = [
    {"id": 1, "nombre": "Estación Norte", "ubicacion": "Norte"},
    {"id": 2, "nombre": "Estación Sur", "ubicacion": "Sur"}
]

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if form_data.username == "jordybujaicob-netizen" and form_data.password == "jordybujaicob-netizen":
        return {"access_token": "token-secreto-abc", "token_type": "bearer"}
    raise HTTPException(status_code=400, detail="Credenciales incorrectas")

@app.get("/estaciones/", response_model=List[Estacion])
async def get_estaciones(token: str = Depends(oauth2_scheme)):
    return db_estaciones

# CREAR (POST): Soluciona el problema de "Error al guardar"
@app.post("/estaciones/", status_code=201)
async def crear_estacion(estacion: Estacion, token: str = Depends(oauth2_scheme)):
    nueva = estacion.dict()
    nueva["id"] = max([e["id"] for e in db_estaciones], default=0) + 1
    db_estaciones.append(nueva)
    return nueva

# EDITAR (PUT): Requerido por el Punto 3 del PDF [cite: 9, 109]
@app.put("/estaciones/{id}")
async def update_estacion(id: int, estacion_upd: Estacion, token: str = Depends(oauth2_scheme)):
    for i, est in enumerate(db_estaciones):
        if est["id"] == id:
            db_estaciones[i]["nombre"] = estacion_upd.nombre
            db_estaciones[i]["ubicacion"] = estacion_upd.ubicacion
            return {"message": "Actualizado"}
    raise HTTPException(status_code=404, detail="No encontrado")

# ELIMINAR (DELETE): Requerido por el Punto 2 del PDF [cite: 19, 58]
@app.delete("/estaciones/{id}")
async def delete_estacion(id: int, token: str = Depends(oauth2_scheme)):
    global db_estaciones
    db_estaciones = [e for e in db_estaciones if e["id"] != id]
    return {"message": "Eliminado"}