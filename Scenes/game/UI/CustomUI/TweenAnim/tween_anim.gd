extends Node

class_name TweenAnim

func focus(body : Control, scale_target : float = 1.2)->void:
	body.pivot_offset = body.size / 2
	var scale_ratio = 1.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(body, "scale:x", scale_target, 0.2)
	tween.set_parallel(true)
	tween.tween_property(body, "scale:y", scale_target, 0.35)
	tween.tween_property(body, "rotation_degrees", 5.0 * scale_ratio * [-1.0, 1.0].pick_random(), 0.1)
	tween.tween_property(body, "rotation_degrees", 0.0, 0.1).set_delay(0.1)
	

func unfocus(body : Control, scale_target : float = 1.0)->void:
	body.pivot_offset = body.size /2
	var scale_ratio = 1.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(body, "scale:x", scale_target, 0.2)
	tween.set_parallel(true)
	tween.tween_property(body, "scale:y", scale_target, 0.35)
	tween.tween_property(body, "rotation_degrees", 5.0 * scale_ratio * [-1.0, 1.0].pick_random(), 0.1)
	tween.tween_property(body, "rotation_degrees", 0.0, 0.1).set_delay(0.1)
	pass
