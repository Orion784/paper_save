extends CanvasLayer

@export var time_label : Label
@export var progress_bar : ProgressBar 
@export var menu : TextureRect
@export var menu_shade : TextureRect
@export var menu_button : CustomButton

signal pause

var time_left : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	show_time_left(delta)
	pass

func fill_progress_bar(amount:float) -> void:
	progress_bar.value += amount
	pass

func show_time_left(_delta) -> void :
	time_label.text = str(snapped(time_left, 0.01))
	pass

func time_out() -> void:
	menu.visible = true
	menu_shade.visible = true

func _on_menu_button() -> void:
	if time_left > 0:
		menu.visible = !menu.visible
		menu_shade.visible = menu.visible
		pause.emit()
	pass # Replace with function body.

func init() -> void:
	self.visible = true
	time_label.visible = true
	progress_bar.visible = true
	menu_button.visible = true
	menu.visible = false
	menu_shade.visible = false
	progress_bar.value = 0
	pass

func dispose() -> void:
	self.visible = false
	time_label.visible = false
	progress_bar.visible = false
	menu_button.visible = false
	menu.visible = false
	menu_shade.visible = false
	pass
