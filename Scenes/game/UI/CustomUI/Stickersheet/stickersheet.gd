extends PanelContainer

class_name Stickersheet
@export var texturita : Texture2D
@export var animation : TweenAnim
@export var container : Control
@export var shadow : CustomShadow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texturita:
		$TextureRect.texture = texturita
	if container:
		shadow.container = container
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shadow.handle_shadow_process(delta)
	pass

func _on_mouse_entered() -> void:
	animation.focus(self, 1.1)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	animation.unfocus(self)
	pass # Replace with function body.
