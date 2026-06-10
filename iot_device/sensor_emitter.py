import requests
import time
import random

# CONFIGURACIÓN
API_URL = "http://localhost:8000/estaciones/1"
ESTACION_ID = 1 
TOKEN = "TOKEN_ESTATICO_SEGURO_SMAT_2026"

def leer_sensor_emulado():
    return int(random.uniform(10.5, 85.0))

def enviar_telemetria():
    print(f"--- Iniciando Emisor IoT para Estación {ESTACION_ID} ---")
    
    while True:
        valor = leer_sensor_emulado()
        payload = {
            "valor": valor,
            "estacion_id": ESTACION_ID
        }
        headers = {
            "Authorization": f"Bearer {TOKEN}"
        }

        payload.update({
            "id": ESTACION_ID,
            "nombre": "Estacion Norte",
            "ubicacion": "Norte"
        })

        try:
            response = requests.put(API_URL, json=payload, headers=headers)
            if response.status_code == 200:
                print(f"[OK] Lectura enviada: {valor} cm")
            else:
                print(f"[ERROR] Código: {response.status_code}")
        except Exception as e:
            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")

        # Esperar 5 segundos para la siguiente lectura
        time.sleep(5)

if __name__ == "__main__":
    enviar_telemetria()