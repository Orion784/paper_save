extends PanelContainer

@export var stack: Array[Stickersheet] = [] # stack[0] = el del frente
var current_sheet: Stickersheet

@export var shift_ratio := 1.1   # 1.0 = ancho completo de la hoja, 1.1 = un poco más
@export var tilt := 6.0          # inclinación en grados
@export var back_scale := 0.9    # escala cuando está al fondo
var busy : bool = false


func _ready() -> void:
	current_sheet = stack[0] #Apuntamos al primero
	_update_mouse_filters() # Actualizamos quien debe responder al input del mouse


func move_behind() -> void:
	if busy:	
		return
	busy = true

	var body: Stickersheet = stack.pop_front() #quitamos del stack al primero
	stack.push_back(body)	#lo agregamos al final
	current_sheet = stack[0] # refrescamos el apuntador

	_block_all_mouse() #se bloquean los input
	
	await _swing(body, true) #esperamos a que termine el movimiento

	_update_mouse_filters() #activamos el input del primero
	
	busy = false

func move_front() -> void:
	if busy or stack.size() < 2:
		return
	busy = true

	var body: Stickersheet = stack.pop_back()
	stack.push_front(body)
	current_sheet = body

	_block_all_mouse()
	await _swing(body, false)

	_update_mouse_filters()
	busy = false

# Solo la hoja al frente de la pila recibe input del mouse
func _update_mouse_filters() -> void:
	for sheet in stack.size():
		if sheet == 0:
			stack[sheet].mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			stack[sheet].mouse_filter = Control.MOUSE_FILTER_IGNORE

# Bloquea el mouse en todas las hojas (durante la animación)
func _block_all_mouse() -> void:
	for sheet in stack:
		sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE

#Movimiento hacia delante o atras
func _swing(body: Stickersheet, to_back: bool) -> void:
	body.pivot_offset = body.size / 2.0

	# Desplazamiento relativo al ancho real de la hoja (compensando su escala actual)
	var shift := body.size.x * body.scale.x * shift_ratio

	# Escala: un tween aparte que dura todo el movimiento (0.4 s)
	var target_scale := Vector2.ONE * (back_scale if to_back else 1.0)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK) \
		.tween_property(body, "scale", target_scale, 0.4)

	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Fase 1: derecha + inclinada
	tween.tween_property(body, "offset_transform_position:x", shift, 0.2)
	tween.parallel().tween_property(body, "rotation_degrees", tilt, 0.2)

	# A mitad: cambia el orden de dibujo (0 = fondo, -1 = frente)
	tween.tween_callback(move_child.bind(body, 0 if to_back else -1))

	# Fase 2: regresa a la izquierda y se endereza
	tween.tween_property(body, "offset_transform_position:x", 0.0, 0.2)
	tween.parallel().tween_property(body, "rotation_degrees", 0.0, 0.2)

	await tween.finished
