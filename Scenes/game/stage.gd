extends Node2D

class_name Stage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func init():
	visible = true
	$CanvasLayer.visible = true
	$EntityManager.start_ufos()
	pass

func dispose():
	$CanvasLayer.visible = false
	visible = false
	pass

func shoot_fired(center:Vector2, radius : float, damage: float) -> void:
	$EntityManager.apply_shoot(center,radius,damage)
	pass
