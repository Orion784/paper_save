@abstract
extends Resource

class_name State

@abstract
func enter(entity:Node)

@abstract
func exit(entity:Node)

func switch(entity:Node, state_name:String):
	if entity:
		entity.current_state.exit(entity)
		entity.switch_state(state_name)

#
#extends Node2D
#
#@export var states : Array[State] = []
#var state_dict :  Dictionary[String, State] = {}
#var active_state : State = null
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#for state in states:
		#state_dict[state.name] = state
		#active_state = states[0]
		#active_state.enter(self)
	#pass # Replace with function body.
#
#func switch_state(state_name :String):
	#active_state = state_dict[state_name]
	#active_state.enter(self)
#
#
##func recibir archivo y enivarlo a data para que lo gestione
##func crear y/o reescribir el archivo para la proxima sesion
