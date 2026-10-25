extends Node2D

class_name Stage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func init():
	$CanvasLayer.visible = true
	pass
func dispose():
	$CanvasLayer.visible = false
	pass
