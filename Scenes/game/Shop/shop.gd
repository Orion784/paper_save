extends Node2D

class_name Shop
signal state_change(GameState)

@export var data : DataProfile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dispose()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func init():
	$ShopCanvas.visible = true
	pass
	
func dispose():
	$ShopCanvas.visible = false
	pass


func _on_button_ready() -> void:
	state_change.emit(Enums.GameState.STAGE)
	pass # Replace with function body.
