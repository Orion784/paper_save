extends Node2D

@export var opening_state : Enums.GameState
@export var state_node : Array[Node2D] = []
var current_state : Enums.GameState
var next_state : Enums.GameState
var is_changing: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in state_node:
		node.dispose()
	EventBus.transition_change.connect(switch)
	start()
	pass

func state_transition(state:Enums.GameState)->void:
	is_changing = true
	$Transition/ColorRect.fade_in()
	next_state = state
	pass
func switch(state : Enums.GameState = next_state):
	exit(current_state)
	current_state = state
	enter(current_state)
	is_changing = false
	pass
func enter(state : Enums.GameState):
	state_node[state].init()
	pass
func exit(state):
	state_node[state].dispose()
	pass
func start()->void:
	for node in state_node:
		node.dispose()
	current_state = opening_state
	enter(current_state)
	pass # Replace with functiopass
