extends Node2D


@export var base_damage : float
@export var crit_damage : float
@export var crit_chance : float # 0.1 - 1.0
@onready var radius : float = 12.0
@export var shot_timer: float = 0.5
#@export var recharge_speed : float
#@export var ammo : int

var paused : bool = false

signal shoot_fired(center: Vector2, radius: float, damage:float)

func setup(_a : Dictionary) -> void:
	#inicializa las variables con los valores del diccionario
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = get_global_mouse_position()
	if !paused:
		$Sprite2D.rotation += _delta * 3
		if $Sprite2D.rotation > 360:
			$Sprite2D.rotation = 0
		update_damage(_delta)


func damage_output() -> float:
	if randf() <= crit_chance:
		return base_damage*crit_damage
	else:
		return base_damage #se envia el rango, el daño, el multiplicador

func update_damage(_delta) -> void:
	if shot_timer > 0.0:
		shot_timer -= _delta
	else:
		shoot_fired.emit(global_position, radius, damage_output())
		shot_timer = 0.5
	pass
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("shoot"):
		#shoot_fired.emit(global_position, radius, damage_output())
