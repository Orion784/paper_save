extends Node2D

class_name MainMenu
signal state_change(GameState)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func init():
	$MenuCanvas.visible = true
	pass
	
func dispose():
	$MenuCanvas.visible = false
	
	pass


func _on_button_quit() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_button_play() -> void:
	state_change.emit(Enums.GameState.SHOP)
	pass # Replace with function body.
