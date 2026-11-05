extends Button

class_name CustomButton

@export var container : Control
# Called when the node enters the scene tree for the first time.
@export var animation : TweenAnim
@export var shadow: CustomShadow
@export var current_shadow_size : Enums.ShadowSize
@onready var textodelboton : RichTextLabel = $RichTextLabel

func _ready() -> void:
	if container:
		shadow.container = container
	textodelboton.text = text
	if current_shadow_size:
		shadow.current_shadow_size = current_shadow_size
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hover_in()->void:
	animation.focus(self)
	

func hover_out()->void:
	animation.unfocus(self)
