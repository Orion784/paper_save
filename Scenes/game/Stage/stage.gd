extends Node2D

class_name Stage
signal state_change(GameState)

@export var data : DataProfile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$StageCanvas.update_time_label($Timer.time_left)
	$StageCanvas.update_money(data.money)
	pass

func init():
	$EntityManager.initial_spawn()
	$Timer.start(31)
	visible = true
	$Background.visible = true
	$StageCanvas.init()
	$Player.paused = false
	$Timer.paused = false
	$EntityManager.paused = false
	
	pass

func dispose():
	$Background.visible = false
	visible = false
	$StageCanvas.dispose()
	$EntityManager.paused = true
	$EntityManager.clear_ufos()
	$Timer.stop()
	#mandar el dinero del stage a la data
	
	pass

func on_button_shop() -> void:
	state_change.emit(Enums.GameState.SHOP)
	pass

func shoot_fired(center:Vector2, radius : float, damage: float, ammo: int) -> void:
	$EntityManager.apply_shoot(center,radius,damage)
	$StageCanvas.hide_ammo()
	#le decimos a stagecanvas que disminuya el [chamber]
	pass


func on_button_retry() -> void:
	state_change.emit(Enums.GameState.STAGE)
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	$StageCanvas.time_out()
	$Player.paused = true
	
	pass # Replace with function body.

func _on_pause() -> void:
	$EntityManager.paused = !$EntityManager.paused
	$Timer.paused = !$Timer.paused
	$Player.paused = !$Player.paused
	pass # Replace with function body.

func experience_gained(amount: float) -> void:
	$StageCanvas.fill_progress_bar(amount)
	pass # Replace with function body.


func ammo_reset() -> void:
	$StageCanvas.reset_ammo()
	pass # Replace with function body.
