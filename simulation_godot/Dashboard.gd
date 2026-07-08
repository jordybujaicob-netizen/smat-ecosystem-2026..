extends Node2D

@onready var sensor = $Estacion_1
@onready var label = $Estacion_1/Label

var tiempo = 0.0

func _ready():
	print("Dashboard SMAT iniciado")
	actualizar_sensor(0)

func _process(delta):
	tiempo += delta
	
	if tiempo >= 1.0:
		tiempo = 0.0
		leer_dato_smat()

func leer_dato_smat():
	var path = "C:/Users/Asus/Downloads/smat-ecosystem-2026-main/smat-ecosystem-2026-main/simulation/latest_reading.json"

	if not FileAccess.file_exists(path):
		print("Esperando datos de SMAT...")
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var contenido = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(contenido)
	
	if data == null:
		print("JSON inválido")
		return
	
	if data.has("valor"):
		actualizar_sensor(float(data["valor"]))

func actualizar_sensor(valor):
	label.text = str(valor) + " cm"
	
	if valor > 70:
		sensor.color = Color.RED
		print("🔴 ALERTA SMAT: ", valor)
	else:
		sensor.color = Color.GREEN
		print("🟢 NORMAL SMAT: ", valor)
