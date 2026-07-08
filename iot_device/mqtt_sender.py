import paho.mqtt.client as mqtt
import json
import time
import random
import os

BROKER = "broker.hivemq.com"
PORT = 1883
TOPIC = "fisi/smat/estaciones/1/lecturas"

client = mqtt.Client()
client.connect(BROKER, PORT)
client.loop_start()

print("📡 Sensor SMAT enviando datos...")

while True:
    payload = {
        "valor": round(random.uniform(20.0, 90.0), 2),
        "timestamp": time.time()
    }

    # Sigue publicando por MQTT
    client.publish(TOPIC, json.dumps(payload))

    # Además escribe el dato para que Godot lo lea
    os.makedirs("simulation", exist_ok=True)
    with open("simulation/latest_reading.json", "w", encoding="utf-8") as f:
        json.dump(payload, f)

    print("Archivo creado en:", os.path.abspath("simulation/latest_reading.json"))
    print(f"📡 Sensor: Enviado por MQTT y Godot: {payload}")
    time.sleep(3)