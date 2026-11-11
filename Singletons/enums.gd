extends Node

enum GameState {MAIN, SHOP, STAGE}

enum ShadowSize {SMALL, MEDIUM ,LARGE}

# Instanciamos el objeto RNG
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	# Opcional pero recomendado: Inicializa la semilla aleatoria
	rng.randomize()

# Función para obtener un número entero aleatorio entre min y max (inclusive)
func rand_int(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)

# Función para obtener un número decimal (float) entre min y max
func rand_float(min_val: float, max_val: float) -> float:
	return rng.randf_range(min_val, max_val)# Nota: rand_range cambió a randf_range en Godot 4
