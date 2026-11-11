extends Node

class_name EntityManager


var paused: bool = true
signal experience_gained(amount:float)

@onready var play_area : Rect2 = get_viewport().get_visible_rect() #MAl, ajustarlo
@onready var inner: Rect2 = play_area.grow(-stats.UFO_RADIUS) #bordea la zona para que no haya errores
@onready var multimesh: MultiMesh = $MultiMeshInstance2D.multimesh
@onready var damage_label: DamageNumbers = $DamageLabel
@onready var timer: float = stats.SPAWN_TIMER
@export var stats : UfoProfile
#Datos importantes

#Datos de animación
const PENDULUM_AMPLITUDE: float = 0.45   # radianes, unos 26° hacia cada lado
const PENDULUM_SPEED: float = 2.5        # radianes de fase por segundo
const PENDULUM_HIT_BOOST: float = 2.0    # extra máximo: 3.0 = 4x la velocidad base
const PENDULUM_BOOST_TIME: float = 0.8   # segundos que tarda en volver a la normalidad
const VIBRATION_AMPLITUDE: float = 1.00
const HIT_FLASH_TIME: float = 0.50
const DEATH_TIME: float = 0.5
const BIRTH_TIME: float = 0.5            # nuevo: mismo valor que DEATH_TIME para que sea espejo

# NUEVO: rebote al recibir daño
const BOUNCE_TIME: float = 0.35          # duración total del rebote (segundos)
const BOUNCE_SHRINK: float = 0.9        # escala mínima (se encoge un poco)
const BOUNCE_GROW: float = 1.1          # escala máxima (se agranda más de lo normal)
const BOUNCE_SHRINK_END: float = 0.25    # fracción del tiempo en que termina de encogerse
const BOUNCE_GROW_END: float = 0.60      # fracción del tiempo en que alcanza el tamaño máximo

#Declaracion de los arreglos | Packed es un tipo especial que ahorra espacio
#Datos importantes
var positions: PackedVector2Array
var velocities: PackedVector2Array
var health: PackedInt32Array
var experience: PackedFloat32Array
#Datos de animación
var phases: PackedFloat32Array
var pendulum_boosts: PackedFloat32Array  # nuevo: velocidad extra del péndulo tras un golpe
var stun_timers: PackedFloat32Array
var flash_timers: PackedFloat32Array
var death_timers: PackedFloat32Array
var birth_timers: PackedFloat32Array     # nuevo
var bounce_timers: PackedFloat32Array    # NUEVO: tiempo restante del rebote

#Ufos activados
var active_count: int = 0

func _ready() -> void:
	init_pool()
	setup_multimesh()

func spawn_ufo(spawn_position: Vector2) -> bool:
	#Si los ufos actuales son mayores a la cantidad maxima,
	#entonces no se hace nada
	if active_count >= stats.MAX_UFOS:
		return false
	var i: int = active_count # i = instancia en el ultimo espacio disponible
	positions[i] = spawn_position
	velocities[i] = Vector2.from_angle(randf() * TAU) * stats.UFO_SPEED * Enums.rand_float(1.0, 1.5)#TAU = 2PI
	phases[i] = randf() * TAU
	pendulum_boosts[i] = 0.0
	health[i] = stats.UFO_HEALTH
	flash_timers[i] = 0.0
	death_timers[i] = DEATH_TIME
	birth_timers[i] = BIRTH_TIME
	bounce_timers[i] = 0.0        # NUEVO
	stun_timers[i] = BIRTH_TIME   # quieto y vibrando mientras nace
	#Una vez inicializado, entonces aumentamos el conteo a uno
	active_count += 1
	return true

func _process(delta: float) -> void:
	if !paused :
		update_movement(delta)
		update_pendulum(delta)
		update_pendulum_boost(delta)
		update_flash(delta)
		update_bounce(delta)      # NUEVO
		update_birth(delta)
		update_death(delta)
		update_spawns(delta)
	sync_multimesh()




func init_pool() -> bool:
	#Le damos tamaño a los arreglos
	positions.resize(stats.MAX_UFOS)
	velocities.resize(stats.MAX_UFOS)
	phases.resize(stats.MAX_UFOS)
	pendulum_boosts.resize(stats.MAX_UFOS)
	health.resize(stats.MAX_UFOS)
	experience.resize(stats.MAX_UFOS	)
	stun_timers.resize(stats.MAX_UFOS)
	flash_timers.resize(stats.MAX_UFOS)
	death_timers.resize(stats.MAX_UFOS)
	birth_timers.resize(stats.MAX_UFOS)
	bounce_timers.resize(stats.MAX_UFOS)   # NUEVO
	active_count = 0
	return true
func setup_multimesh() -> void:
	#obligatorio. Atributos de multimesh
	multimesh.instance_count = stats.MAX_UFOS
	multimesh.visible_instance_count = 0
func initial_spawn() -> void:
	for i in stats.MAX_INITIAL_UFOS:
		spawn_ufo(inner.position + Vector2(randf(), randf()) * inner.size)
	pass
func update_movement(delta: float) -> void:
	#Esto idealmente tomaria de una seccion que yo determine
	#no del viewport
	var min_x: float = play_area.position.x + stats.UFO_RADIUS
	var max_x: float = play_area.end.x - stats.UFO_RADIUS
	var min_y: float = play_area.position.y + stats.UFO_RADIUS
	var max_y: float = play_area.end.y - stats.UFO_RADIUS
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
		# la velocidad base se multiplica por (1 + impulso): 4x al golpe, decae hasta 1x
		phases[i] = wrapf(phases[i] + PENDULUM_SPEED * (1.0 + pendulum_boosts[i]) * delta, 0.0, TAU)
# nuevo: el impulso baja linealmente hasta 0
func update_pendulum_boost(delta: float) -> void:
	var decay: float = PENDULUM_HIT_BOOST / PENDULUM_BOOST_TIME * delta
	for i in active_count:
		if pendulum_boosts[i] > 0.0:
			pendulum_boosts[i] = maxf(pendulum_boosts[i] - decay, 0.0)
func update_spawns(_delta) -> void:
	timer -= _delta
	if timer < 0 :
		if active_count < (stats.MAX_INITIAL_UFOS * 2) and Enums.rand_float(0,1) < stats.SPAWN_RATE:
			for i in stats.SPAWN_PACK:
				spawn_ufo(inner.position + Vector2(randf(), randf()) * inner.size)
		timer = stats.SPAWN_TIMER
	pass
func update_flash(delta: float) -> void:
	for i in active_count:
		if flash_timers[i] > 0.0:
			flash_timers[i] = maxf(flash_timers[i] - delta, 0.0)
# NUEVO: el timer de rebote baja hasta 0
func update_bounce(delta: float) -> void:
	for i in active_count:
		if bounce_timers[i] > 0.0:
			bounce_timers[i] = maxf(bounce_timers[i] - delta, 0.0)
# nuevo: el timer de nacimiento baja hasta 0
func update_birth(delta: float) -> void:
	for i in active_count:
		if birth_timers[i] > 0.0:
			birth_timers[i] = maxf(birth_timers[i] - delta, 0.0)
# Recorrido inverso porque remove_ufo hace swap con el último
func update_death(delta: float) -> void:
	for i in range(active_count - 1, -1, -1):
		if health[i] > 0:
			continue
		death_timers[i] -= delta
		if death_timers[i] <= 0.0:
			$Particles.burst(positions[i])
			remove_ufo(i)
# NUEVO: devuelve el multiplicador de escala del rebote (1.0 = sin efecto)
# Tres tramos: 1.0 -> SHRINK (se encoge) -> GROW (se agranda de más) -> 1.0 (se asienta)
func bounce_scale(time_left: float) -> float:
	if time_left <= 0.0:
		return 1.0
	var p: float = 1.0 - time_left / BOUNCE_TIME   # 0 = recién golpeado, 1 = terminó
	if p < BOUNCE_SHRINK_END:
		var t: float = p / BOUNCE_SHRINK_END
		return lerpf(1.0, BOUNCE_SHRINK, smoothstep(0.0, 1.0, t))
	elif p < BOUNCE_GROW_END:
		var t: float = (p - BOUNCE_SHRINK_END) / (BOUNCE_GROW_END - BOUNCE_SHRINK_END)
		return lerpf(BOUNCE_SHRINK, BOUNCE_GROW, smoothstep(0.0, 1.0, t))
	else:
		var t: float = (p - BOUNCE_GROW_END) / (1.0 - BOUNCE_GROW_END)
		return lerpf(BOUNCE_GROW, 1.0, smoothstep(0.0, 1.0, t))
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

		#Efecto visual de nacimiento (espejo de la muerte)
		var birth_progress: float = clampf(birth_timers[i] / BIRTH_TIME, 0.0, 1.0)   # 1 = recién nacido, 0 = listo

		#Efecto visual de muerte
		var death_progress: float = 0.0   # 0 = visible, 1 = desaparecido
		var flash_progress: float = flash_timers[i] / HIT_FLASH_TIME
		if health[i] <= 0:
			death_progress = 1.0 - clampf(death_timers[i] / DEATH_TIME, 0.0, 1.0)
			flash_progress = 1.0   # los que mueren se quedan blancos

		# Nacer y morir comparten escala, transparencia y blanco
		var fade_progress: float = maxf(death_progress, birth_progress)
		flash_progress = maxf(flash_progress, birth_progress)

		var diminish: float = 1.0 - fade_progress   # se encoge al morir, crece al nacer
		diminish *= bounce_scale(bounce_timers[i])  # NUEVO: rebote al recibir daño
		#envia datos para el dibujo
		multimesh.set_instance_transform_2d(i, Transform2D(angle, Vector2(1, -1) * diminish, 0.0, draw_pos))

		var frame: int = clampi(stats.UFO_HEALTH - health[i], 0, 2)
		#envia datos para el shader
		multimesh.set_instance_custom_data(i, Color(frame, flash_progress, fade_progress, 0))
	
	multimesh.visible_instance_count = active_count

#Funciones de juego

func apply_shoot(center : Vector2, radius : float, damage: int) -> void:
	var hit_distance = intersection(radius)
	var total_experience : int = 0
	for i in range(active_count - 1, -1, -1):
		if health[i] <= 0 or birth_timers[i] > 0.0:
			continue   # muriendo o naciendo, no se golpea
		if distance(center, positions[i]) <= hit_distance:
			health[i] -= damage
			flash_timers[i] = HIT_FLASH_TIME
			pendulum_boosts[i] = PENDULUM_HIT_BOOST   # nuevo: el péndulo se acelera de golpe
			damage_label.spawn(positions[i] + Vector2(0, -stats.UFO_RADIUS), damage)
			if health[i] <= 0:
				death_timers[i] = DEATH_TIME
				stun_timers[i] = DEATH_TIME   # quieto (y vibrando) mientras muere
				total_experience += 1
			else:
				#stun_timers[i] = 0.50 probando sin esto
				bounce_timers[i] = BOUNCE_TIME   # NUEVO: solo rebota si sobrevive al golpe
	if total_experience > 0 :
		experience_gained.emit(total_experience * stats.UFO_EXPERIENCE)

func remove_ufo(i: int) -> void:
	if i < 0 or i >= active_count:
		return
	var last: int = active_count - 1
	positions[i] = positions[last]
	velocities[i] = velocities[last]
	phases[i] = phases[last]
	pendulum_boosts[i] = pendulum_boosts[last]
	health[i] = health[last]
	stun_timers[i] = stun_timers[last]
	flash_timers[i] = flash_timers[last]
	death_timers[i] = death_timers[last]
	birth_timers[i] = birth_timers[last]
	bounce_timers[i] = bounce_timers[last]   # NUEVO: sin esto, el UFO que ocupa el hueco heredaría un rebote ajeno
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
	return (radius + stats.UFO_RADIUS)**2
#Trucazo de pitagoras para no calcular la raiz cuadrada
# sqr(a^2 + b^2) = c  Es lo mismo que (a^2 + b^2) = c^2
#la distancia y la interseccion estan elevadas al cuadrado
