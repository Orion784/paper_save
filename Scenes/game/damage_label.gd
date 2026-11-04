extends Node2D
class_name DamageNumbers

const MAX_NUMBERS := 300
const LIFETIME := 0.8
const RISE := 48.0
const SUFFIXES := ["", "K", "M", "B", "T"]

@export var font: Font              # arrastrá tu TTF acá
@export var font_size := 20
@export var gradient: Gradient      # blanco -> amarillo -> rojo, lo armás en el inspector

var _pos := PackedVector2Array()
var _age := PackedFloat32Array()
var _color := PackedColorArray()
var _text: Array[String] = []
var _count := 0


func _ready() -> void:
	_pos.resize(MAX_NUMBERS)
	_age.resize(MAX_NUMBERS)
	_color.resize(MAX_NUMBERS)
	_text.resize(MAX_NUMBERS)


func spawn(pos: Vector2, amount: int) -> void:
	if _count >= MAX_NUMBERS:
		return   # lleno: se ignora, nadie va a leerlo igual
	_pos[_count] = pos
	_age[_count] = 0.0
	_text[_count] = format_amount(amount)
	_color[_count] = color_for(amount)
	_count += 1


func _process(delta: float) -> void:
	for i in range(_count - 1, -1, -1):
		_age[i] += delta
		if _age[i] >= LIFETIME:
			_count -= 1
			_pos[i] = _pos[_count]
			_age[i] = _age[_count]
			_color[i] = _color[_count]
			_text[i] = _text[_count]
	queue_redraw()


func _draw() -> void:
	var f: Font = font if font else ThemeDB.fallback_font
	for i in _count:
		var t: float = _age[i] / LIFETIME
		var p: Vector2 = _pos[i] + Vector2(0, -RISE * (1.0 - (1.0 - t) * (1.0 - t)))
		var c: Color = _color[i]
		c.a = 1.0 - smoothstep(0.6, 1.0, t)
		# Caja de 200px centrada en p: así el texto queda centrado sin medirlo
		draw_string(f, p - Vector2(100, 0), _text[i], HORIZONTAL_ALIGNMENT_CENTER, 200, font_size, c)


func format_amount(v: int) -> String:
	var f := float(v)
	var tier := 0
	while f >= 1000.0 and tier < SUFFIXES.size() - 1:
		f /= 1000.0
		tier += 1
	if tier == 0:
		return str(v)
	var s := "%.1f" % (floorf(f * 10.0) / 10.0)
	return s.trim_suffix(".0") + SUFFIXES[tier]


func color_for(amount: int) -> Color:
	# Escala logarítmica: 10^7 = color final del gradiente
	var t := clampf(log(maxf(amount, 1.0)) / log(10.0) / 7.0, 0.0, 1.0)
	return gradient.sample(t)
