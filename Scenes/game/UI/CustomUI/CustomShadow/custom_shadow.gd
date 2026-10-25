extends TextureRect

class_name CustomShadow

@export var container : Control
@export var parent: Control
@export var horizontal_movement : bool = false
@export var vertical_movement : bool = false
var shadow_size = [20.0, 50.0, 100.0]
@export var current_shadow_size : Enums.ShadowSize

func hide_shadow() -> void:
	visible = false

func show_shadow() -> void:
	visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "icon" in parent:
		texture = parent.icon
	if "texture" in parent:
		texture = parent.texture
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_shadow_process(delta)
	pass

func handle_shadow() -> void:
	#Algunos contenedores pueden interferir en laposicion global de la sombra
	var current_position_x = parent.global_position.x + parent.size.x / 2
	var current_position_y = parent.global_position.y
	if container == VBoxContainer:
		current_position_x = container.global_position.x + container.get_size().x /2
		current_position_y = container.global_position.y + parent.global_position.y
	if container == HBoxContainer:
		current_position_x = container.global_position.x + parent.global_position.x + parent.size.x / 2
		current_position_y = container.global_position.y
	#Es una reverenda paja
	
	var center: Vector2 = get_viewport_rect().size /2
	var distance_x: float = current_position_x - center.x 
	var distance_y: float = current_position_y - center.y
	if horizontal_movement:
		#Moverse a: +- 100 veces |x1/x2|(proporcion razon escalar)
		position.x = (-sign(distance_x) * shadow_size[current_shadow_size]  * abs(distance_x/(center.x)))
	if vertical_movement:
		position.y = (-sign(distance_y) * shadow_size[current_shadow_size] * abs(distance_y/(center.y)))

func handle_shadow_process(_delta:float) -> void:
	#Algunos contenedores pueden interferir en laposicion global de la sombra
	var current_position_x = parent.global_position.x + parent.size.x / 2
	var current_position_y = parent.global_position.y
	if container == VBoxContainer:
		current_position_x = container.global_position.x + container.get_size().x /2
		current_position_y = container.global_position.y + parent.global_position.y
	if container == HBoxContainer:
		current_position_x = container.global_position.x + parent.global_position.x + parent.size.x / 2
		current_position_y = container.global_position.y
	#Es una reverenda paja
	
	var center: Vector2 = get_viewport_rect().size /2
	var distance_x: float = current_position_x - center.x 
	var distance_y: float = current_position_y - center.y
	if horizontal_movement:
		#Moverse a: +- 100 veces |x1/x2|(proporcion razon escalar)
		position.x = lerp(0.0, -sign(distance_x) * shadow_size[current_shadow_size] , abs(distance_x/(center.x)))
	if vertical_movement:
		position.y = lerp(0.0, -sign(distance_y) * shadow_size[current_shadow_size] , abs(distance_y/(center.y)))
