# 1. Imagen base ligera de Python
FROM python:3.11-slim

# 2. Definir el directorio de trabajo
WORKDIR /app

# 3. Instalar las librerías directamente ya que son pocas
RUN pip install --no-cache-dir paho-mqtt requests

# 4. Copiar el script del puente
COPY mqtt_bridge.py .

# 5. Ejecutar el daemon
CMD ["python", "mqtt_bridge.py"]