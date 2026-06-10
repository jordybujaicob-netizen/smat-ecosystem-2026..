from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
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

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class Estacion(BaseModel):
    id: int | None = None
    nombre: str
    ubicacion: str
    valor: int = 0 

class Lectura(BaseModel):
    estacion_id: int
    valor: float 

db_estaciones = [
    {"id": 1, "nombre": "Estacion Norte", "ubicacion": "Norte", "valor": 8},
    {"id": 2, "nombre": "Fisi-Test", "ubicacion": "Sistemas", "valor": 69}
]

def obtener_usuario_actual(token: str = Depends(oauth2_scheme)):
    token_limpio = token.replace("Bearer ", "").strip()
    if token_limpio == "TOKEN_ESTATICO_SEGURO_SMAT_2026":
        return "admin"
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, 
        detail="Token inválido o expirado"
    )

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if form_data.username == "admin" and form_data.password == "admin":
        return {
            "access_token": "TOKEN_ESTATICO_SEGURO_SMAT_2026", 
            "token_type": "bearer"
        }
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, 
        detail="Credenciales incorrectas"
    )

@app.get("/estaciones/", response_model=List[Estacion])
async def get_estaciones():
    return db_estaciones

@app.post("/estaciones/", response_model=Estacion, status_code=201)
async def create_estacion(est: Estacion, usuario: str = Depends(obtener_usuario_actual)):
    nueva = est.model_dump(exclude_unset=True) if hasattr(est, "model_dump") else est.dict(exclude_unset=True)
    nueva["id"] = len(db_estaciones) + 1
    db_estaciones.append(nueva)
    return nueva

@app.put("/estaciones/{id}", response_model=Estacion)
async def update_estacion(id: int, est: Estacion, usuario: str = Depends(obtener_usuario_actual)):
    for i, e in enumerate(db_estaciones):
        if e["id"] == id:
            db_estaciones[i] = est.dict()
            db_estaciones[i]["id"] = id
            return db_estaciones[i]
    raise HTTPException(status_code=404, detail="No encontrada")

@app.delete("/estaciones/{id}")
async def delete_estacion(id: int, usuario: str = Depends(obtener_usuario_actual)):
    global db_estaciones
    for e in db_estaciones:
        if e["id"] == id:
            db_estaciones = [x for x in db_estaciones if x["id"] != id]
            return {"ok": True}
    raise HTTPException(status_code=404, detail="No encontrada")

@app.post("/lecturas/")
async def recibir_lectura(lectura: Lectura):
    for e in db_estaciones:
        if e["id"] == lectura.estacion_id:
            e["valor"] = int(round(lectura.valor))
            print(f"📡 API: Recibido decimal {lectura.valor} -> Guardado como entero para Flutter: {e['valor']}")
            return {"status": "Dato persistido exitosamente"}
            
    raise HTTPException(status_code=404, detail="Estación no encontrada")