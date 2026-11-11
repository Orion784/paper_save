extends Node2D

class_name Player

@export var stats : PlayerProfile
#@export var recharge_speed : float
@export var ammo : int = 6

var paused : bool = true
@onready var cadence: float = stats.shot_timer

signal shoot_fired(center: Vector2, radius: float, damage:float, ammo: int)
signal ammo_reset
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
	if randf() <= stats.crit_chance:
		return stats.base_damage*stats.crit_damage
	else:
		return stats.base_damage #se envia el rango, el daño, el multiplicador

func update_damage(_delta) -> void:
	if cadence > 0.0:
		cadence -= _delta
	else:
		if ammo_empty():
			reset_ammo()
			cadence = stats.shot_timer
			ammo_reset.emit()
		else:
			shoot_fired.emit(global_position, stats.radius, damage_output(), ammo)
			decrease_ammo()
			Sfx.play()
			cadence = stats.shot_timer
		
	pass
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("shoot"):
		#shoot_fired.emit(global_position, stats.radius, damage_output())

func reset_ammo() -> void:
	ammo = 6
func ammo_empty() -> bool:
	return ammo == 0 
func decrease_ammo() -> void:
	ammo -= 1
func increase_ammo() -> void:
	ammo += 1
