import paho.mqtt.client as mqtt
import requests
import json
import sys
import time 

# CONFIGURACIÓN DEL ENTORNO SMAT
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "fisi/smat/estaciones/+/lecturas" # El '+' es un wildcard para el ID de la estación

API_URL = "http://localhost:8000/lecturas/"
# Token JWT generado previamente desde Swagger o la App móvil para el usuario administrador
JWT_TOKEN = "TOKEN_ESTATICO_SEGURO_SMAT_2026" 

cache_estaciones = {}

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("🟢 Conectado exitosamente al Broker MQTT")
        # Suscribirse al tópico global de lecturas de estaciones
        client.subscribe(MQTT_TOPIC)
        print(f"📡 Escuchando transmisiones en el tópico: {MQTT_TOPIC}")
    else:
        print(f"🔴 Error de conexión al Broker. Código de retorno: {rc}")
        sys.exit(1)

def on_message(client, userdata, msg):
    try:
        # 1. Decodificar el payload binario de MQTT a JSON string
        payload_raw = msg.payload.decode("utf-8")
        data_json = json.loads(payload_raw)
        
        # 2. Extraer el ID dinámico de la estación desde la estructura del tópico
        topic_parts = msg.topic.split('/')
        estacion_id = int(topic_parts[-2])  
        
        print(f"📩 Telemetría recibida de Estación [{estacion_id}]: {data_json}")

        nuevo_valor = float(data_json["valor"])
        timestamp_actual = time.time()
        debe_enviar = False

        if estacion_id not in cache_estaciones:
            debe_enviar = True
        else:
            ultimo_valor = cache_estaciones[estacion_id]["ultimo_valor"]
            ultimo_timestamp = cache_estaciones[estacion_id]["ultimo_timestamp"]
            
            if ultimo_valor != 0:
                variacion = abs((nuevo_valor - ultimo_valor) / ultimo_valor)
            else:
                variacion = abs(nuevo_valor)
                
            tiempo_transcurrido = timestamp_actual - ultimo_timestamp

            # Si varía más del 5% O pasaron más de 60 segundos
            if variacion > 0.05 or tiempo_transcurrido >= 60.0:
                debe_enviar = True

        if debe_enviar:
            # 3. Formatear la carga útil para cumplir con el esquema (Pydantic Model) de FastAPI
            api_payload = {
                "valor": nuevo_valor,
                "estacion_id": estacion_id
            }

            # 4. Ingestión de datos segura mediante HTTP POST con Header Bearer Token
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {JWT_TOKEN}"
            }
            
            response = requests.post(API_URL, json=api_payload, headers=headers)

            if response.status_code == 200 or response.status_code == 201:
                print(f"💾 [DB Sincronizada] Lectura de {api_payload['valor']} cm guardada en SQLite.")
                cache_estaciones[estacion_id] = {
                    "ultimo_valor": nuevo_valor,
                    "ultimo_timestamp": timestamp_actual
                }
            else:
                print(f"⚠️ [Fallo de Ingesta] API rechazó el dato. Código: {response.status_code} - {response.text}")
        else:
            print(f"🛑 [Filtro Activo] Petición HTTP bloqueada: El valor no varió más del 5% y no han pasado 60s.")

    except KeyError as e:
        print(f"❌ Error de esquema: Falta la llave {e} en el payload MQTT.")
    except ValueError:
        print("❌ Error de casteo: El valor o el ID de la estación no son numéricos.")
    except Exception as e:
        print(f"❌ Error crítico en el Bridge: {e}")

# Inicialización del cliente de red MQTT
bridge_client = mqtt.Client()
bridge_client.on_connect = on_connect
bridge_client.on_message = on_message

try:
    print("🚀 Inicializando el Bridge de Acoplamiento SMAT...")
    bridge_client.connect(MQTT_BROKER, MQTT_PORT, 60)
    # Mantener el hilo escuchando activamente de forma síncrona
    bridge_client.loop_forever()
except KeyboardInterrupt:
    print("\n🛑 Bridge detenido por el administrador.")