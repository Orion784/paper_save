extends TextureButton

class_name Sticker

@export var item : Item
@export var tween : TweenAnim
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_off()
	if item:
		self.texture_normal = item.icon
		$TextureRect.texture = item.icon
		$TextureRect2.texture = item.icon
		$TextureRect3.texture = item.icon
		$TextureRect4.texture = item.icon
	manage_sticker()
	pass

func _on_button_down() -> void:
	item.use()
	manage_sticker()
	pass # Replace with function body.


func manage_sticker() -> void:
	match item.lv:
		0: 
			$TextureRect4.visible = true
		1: 
			$TextureRect4.visible = false
			$TextureRect3.visible = true
		2: 
			$TextureRect3.visible = false
			$TextureRect2.visible = true
		3: 
			$TextureRect2.visible = false
			$TextureRect.visible = true
	pass

func turn_off() -> void :
	$TextureRect.visible = false
	$TextureRect2.visible = false
	$TextureRect3.visible = false
	pass


func _on_mouse_entered() -> void:
	tween.focus(self)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	tween.unfocus(self)
	pass # Replace with function body.
