extends Node2D

class_name DeathParticles
@export var data: DataProfile
# Partículas que salen cuando muere un enemigo: se esparcen, esperan un momento
# y vuelan hacia un punto fijo de la pantalla (arriba a la izquierda).
# Uso: death_particles.burst(posicion_donde_murio)

@export var texture: Texture2D   # opcional: si está vacío se dibujan cuadraditos
@export var color: Color = Color(0.65, 0.3, 0.95)
@export var screen_target: Vector2 = Vector2(32, 32)   # destino en píxeles de PANTALLA
@export var max_particles: int = 1024

# Cantidad y tamaño
const COUNT_MIN: int = 4
const COUNT_MAX: int = 4
const SIZE_MIN: float = 3
const SIZE_MAX: float = 5
# Fase 1: salen disparadas y se frenan solas (drag)
const SCATTER_SPEED_MIN: float = 80.0
const SCATTER_SPEED_MAX: float = 220.0
const SCATTER_DRAG: float = 5.0
# Fase 2: esperan un momento (aleatorio por partícula, así no llegan todas juntas)
const HOLD_MIN: float = 0.15
const HOLD_MAX: float = 0.50
# Fase 3: vuelan al destino, acelerando
const FLY_START_SPEED: float = 400.0
const FLY_ACCEL: float = 1800.0
const ARRIVE_DISTANCE: float = 6.0

var positions: PackedVector2Array
var velocities: PackedVector2Array
var sizes: PackedFloat32Array
var hold_timers: PackedFloat32Array   # > 0: esparciéndose / esperando. <= 0: volando
var fly_speeds: PackedFloat32Array
var active_count: int = 0


func _ready() -> void:
	positions.resize(max_particles)
	velocities.resize(max_particles)
	sizes.resize(max_particles)
	hold_timers.resize(max_particles)
	fly_speeds.resize(max_particles)


# Es lo único que hay que llamar desde afuera
func burst(at: Vector2) -> void:
	var n: int = randi_range(COUNT_MIN, COUNT_MAX)
	for k in n:
		if active_count >= max_particles:
			return
		var i: int = active_count
		positions[i] = at
		velocities[i] = Vector2.from_angle(randf() * TAU) * randf_range(SCATTER_SPEED_MIN, SCATTER_SPEED_MAX)
		sizes[i] = randf_range(SIZE_MIN, SIZE_MAX)
		hold_timers[i] = randf_range(HOLD_MIN, HOLD_MAX)
		fly_speeds[i] = FLY_START_SPEED
		active_count += 1


func _process(delta: float) -> void:
	if active_count == 0:
		return
	var target: Vector2 = get_target()
	var drag: float = exp(-SCATTER_DRAG * delta)   # frenado independiente de los FPS
	# Recorrido inverso porque remove_particle hace swap con la última
	for i in range(active_count - 1, -1, -1):
		if hold_timers[i] > 0.0:
			hold_timers[i] -= delta
			positions[i] += velocities[i] * delta
			velocities[i] *= drag
		else:
			fly_speeds[i] += FLY_ACCEL * delta
			positions[i] = positions[i].move_toward(target, fly_speeds[i] * delta)
			if positions[i].distance_squared_to(target) <= ARRIVE_DISTANCE * ARRIVE_DISTANCE:
				remove_particle(i)
	queue_redraw()


func _draw() -> void:
	for i in active_count:
		if texture:
			draw_texture(texture, positions[i] - texture.get_size() * 0.5)
		else:
			var s: float = sizes[i]
			draw_rect(Rect2(positions[i] - Vector2(s, s) * 0.5, Vector2(s, s)), color)


func remove_particle(i: int) -> void:
	var last: int = active_count - 1
	positions[i] = positions[last]
	velocities[i] = velocities[last]
	sizes[i] = sizes[last]
	hold_timers[i] = hold_timers[last]
	fly_speeds[i] = fly_speeds[last]
	active_count -= 1
	$AudioManager.play()
	data.money += 40

# Convierte el punto de pantalla a las coordenadas de este nodo
# (así sigue funcionando aunque después agregues una Camera2D)
func get_target() -> Vector2:
	return to_local(get_canvas_transform().affine_inverse() * screen_target)
