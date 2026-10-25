extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unlock()
	EventBus.transition_start.connect(lock)
	EventBus.transition_end.connect(unlock)
	pass # Replace with function body.

func lock() ->void:
	visible = true
	pass

func unlock() -> void:
	visible = false
	pass
