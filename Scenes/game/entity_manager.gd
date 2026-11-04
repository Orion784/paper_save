extends Node

class_name EntityManager

var play_area : Rect2

@onready var multimesh: MultiMesh = $MultiMeshInstance2D.multimesh
@onready var damage_label: DamageNumbers = $DamageLabel

#Datos importantes
const MAX_UFOS: int = 2000
const UFO_SPEED: float = 120.0   # píxeles por segundo
const UFO_HEALTH: int = 3
const UFO_RADIUS: float = 48.0
#Datos de animación
const PENDULUM_AMPLITUDE: float = 0.45   # radianes, unos 26° hacia cada lado
const PENDULUM_SPEED: float = 2.5        # radianes de fase por segundo
const VIBRATION_AMPLITUDE: float = 1.00
const HIT_FLASH_TIME: float = 0.50
const DEATH_TIME: float = 0.5
#Declaracion de los arreglos | Packed es un tipo especial que ahorra espacio
#Datos importantes
var positions: PackedVector2Array
var velocities: PackedVector2Array
var health: PackedInt32Array
#Datos de animación
var phases: PackedFloat32Array
var stun_timers: PackedFloat32Array
var flash_timers: PackedFloat32Array
var death_timers: PackedFloat32Array

#Ufos activados
var active_count: int = 0

func _ready() -> void:
	init_pool()
	setup_multimesh()

func init_pool() -> bool:
	#Le damos tamaño a los arreglos
	positions.resize(MAX_UFOS)
	velocities.resize(MAX_UFOS)
	phases.resize(MAX_UFOS)
	health.resize(MAX_UFOS)
	stun_timers.resize(MAX_UFOS)
	flash_timers.resize(MAX_UFOS)
	death_timers.resize(MAX_UFOS)
	active_count = 0
	return true
func setup_multimesh() -> void:
	#obligatorio. Atributos de multimesh
	multimesh.instance_count = MAX_UFOS
	multimesh.visible_instance_count = 0

func start_ufos() -> void: #Cambiar esta puta mierda
	play_area = get_viewport().get_visible_rect() #MAl, ajustarlo
	var inner: Rect2 = play_area.grow(-UFO_RADIUS)
	for n in 20:
		spawn_ufo(inner.position + Vector2(randf(), randf()) * inner.size)
func spawn_ufo(spawn_position: Vector2) -> bool:
	#Si los ufos actuales son mayores a la cantidad maxima,
	#entonces no se hace nada
	if active_count >= MAX_UFOS:
		return false
	var i: int = active_count # i = instancia en el ultimo espacio disponible
	positions[i] = spawn_position
	velocities[i] = Vector2.from_angle(randf() * TAU) * UFO_SPEED #TAU = 2PI
	phases[i] = randf() * TAU
	health[i] = UFO_HEALTH
	stun_timers[i] = 0.0
	flash_timers[i] = 0.0
	death_timers[i] = DEATH_TIME
	#Una vez inicializado, entonces aumentamos el conteo a uno
	active_count += 1
	return true

func _process(delta: float) -> void:
	update_movement(delta)
	update_pendulum(delta)
	update_flash(delta)
	update_death(delta)
	sync_multimesh()

func update_movement(delta: float) -> void:
	#Esto idealmente tomaria de una seccion que yo determine
	#no del viewport
	var min_x: float = play_area.position.x + UFO_RADIUS
	var max_x: float = play_area.end.x - UFO_RADIUS
	var min_y: float = play_area.position.y + UFO_RADIUS
	var max_y: float = play_area.end.y - UFO_RADIUS
	for i in active_count:
		if stun_timers[i] > 0.0:
			stun_timers[i] -= delta
			continue #sale de esta iteracion y pasa a la siguiente
		var pos: Vector2 = positions[i] + velocities[i] * delta
		#Para cada entidad, calculamos su proxima posicion
		var vel: Vector2 = velocities[i]
		#la velocidad puede servir como direccion en este caso
		if pos.x < min_x:
			pos.x = min_x
			vel.x = absf(vel.x)
		elif pos.x > max_x:
			pos.x = max_x
			vel.x = -absf(vel.x)
		if pos.y < min_y:
			pos.y = min_y
			vel.y = absf(vel.y)
		elif pos.y > max_y:
			pos.y = max_y
			vel.y = -absf(vel.y)
			#se invierte la velocidad si escapa de los limites
			#esto funciona siempre que el spawn sea dentro de pantalla
		positions[i] = pos
		velocities[i] = vel
func update_pendulum(delta: float) -> void:
	for i in active_count:
		#la fase de la entidad + su proxima movimiento, 0pi, 2pi
		if stun_timers[i] > 0.0:
			continue
		phases[i] = wrapf(phases[i] + PENDULUM_SPEED * delta, 0.0, TAU)
func update_flash(delta: float) -> void:
	for i in active_count:
		if flash_timers[i] > 0.0:
			flash_timers[i] = maxf(flash_timers[i] - delta, 0.0)
# Recorrido inverso porque remove_ufo hace swap con el último
func update_death(delta: float) -> void:
	for i in range(active_count - 1, -1, -1):
		if health[i] > 0:
			continue
		death_timers[i] -= delta
		if death_timers[i] <= 0.0:
			remove_ufo(i)
func sync_multimesh() -> void:
	for i in active_count:
		#Para cada instancia activa
		#1. Tomatos sus valores
		var angle: float = PENDULUM_AMPLITUDE * sin(phases[i])
		var draw_pos: Vector2 = positions[i]
		#Efecto visual de vibracion
		if stun_timers[i] > 0.0:
			draw_pos += Vector2(
				randf_range(-VIBRATION_AMPLITUDE, VIBRATION_AMPLITUDE),
				randf_range(-VIBRATION_AMPLITUDE, VIBRATION_AMPLITUDE))
		#Efecto visual de muerte
		var death_progress: float = 0.0   # 0 = visible, 1 = desaparecido
		var flash_progress: float = flash_timers[i] / HIT_FLASH_TIME
		if health[i] <= 0:
			death_progress = 1.0 - clampf(death_timers[i] / DEATH_TIME, 0.0, 1.0)
			flash_progress = 1.0   # los que mueren se quedan blancos
		
		var diminish: float = 1.0 - death_progress   # se encoge al morir
		#envia datos para el dibujo
		multimesh.set_instance_transform_2d(i, Transform2D(angle, Vector2(1, -1) * diminish, 0.0, draw_pos))
		
		var frame: int = clampi(UFO_HEALTH - health[i], 0, 2)
		#envia datos para el shader
		multimesh.set_instance_custom_data(i, Color(frame, flash_progress, death_progress, 0))
	
	multimesh.visible_instance_count = active_count

#Funciones de juego

func apply_shoot(center : Vector2, radius : float, damage: int) -> void:
	var hit_distance = intersection(radius)
	for i in range(active_count - 1, -1, -1):
		if health[i] <= 0:
			continue   # ya está muriendo, no se vuelve a golpear
		if distance(center, positions[i]) <= hit_distance:
			health[i] -= damage
			flash_timers[i] = HIT_FLASH_TIME
			damage_label.spawn(positions[i] + Vector2(0, -UFO_RADIUS), damage)
			if health[i] <= 0:
				death_timers[i] = DEATH_TIME
				stun_timers[i] = DEATH_TIME   # quieto (y vibrando) mientras muere
			else:
				stun_timers[i] = 0.50

func remove_ufo(i: int) -> void:
	if i < 0 or i >= active_count:
		return
	var last: int = active_count - 1
	positions[i] = positions[last]
	velocities[i] = velocities[last]
	phases[i] = phases[last]
	health[i] = health[last]
	stun_timers[i] = stun_timers[last]
	flash_timers[i] = flash_timers[last]
	death_timers[i] = death_timers[last]
	active_count -= 1

func clear_ufos() -> void:
	active_count = 0
	multimesh.visible_instance_count = 0


#Funciones simples
func distance(p1 : Vector2, p2 : Vector2) -> float:
	var n : float
	n = (p1.x - p2.x)**2 + (p1.y - p2.y)**2
	return n
func intersection(radius:float) -> float:
	return (radius + UFO_RADIUS)**2
#Trucazo de pitagoras para no calcular la raiz cuadrada
# sqr(a^2 + b^2) = c  Es lo mismo que (a^2 + b^2) = c^2
#la distancia y la interseccion estan elevadas al cuadrado
