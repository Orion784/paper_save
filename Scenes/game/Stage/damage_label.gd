extends Node2D
class_name DamageNumbers

const MAX_NUMBERS := 300
const LIFETIME := 0.8
const POP_END := 0.25        # fracción de vida donde termina el rebote de entrada
const SHRINK_START := 0.6    # fracción de vida donde empieza a encogerse
const MAX_TILT := 12.0       # inclinación máxima en grados (izquierda o derecha)
const SUFFIXES := ["", "K", "M", "B", "T"]

@export var font: Font              # arrastrá tu TTF acá
@export var font_size := 20

var _pos := PackedVector2Array()
var _age := PackedFloat32Array()
var _rot := PackedFloat32Array()
var _color := PackedColorArray()
var _text: Array[String] = []
var _count := 0


func _ready() -> void:
	_pos.resize(MAX_NUMBERS)
	_age.resize(MAX_NUMBERS)
	_rot.resize(MAX_NUMBERS)
	_color.resize(MAX_NUMBERS)
	_text.resize(MAX_NUMBERS)


func spawn(pos: Vector2, amount: int, color: Color = Color.WHITE) -> void:
	if _count >= MAX_NUMBERS:
		return   # lleno: se ignora, nadie va a leerlo igual
	_pos[_count] = pos
	_age[_count] = 0.0
	_rot[_count] = deg_to_rad(randf_range(-MAX_TILT, MAX_TILT))
	_text[_count] = format_amount(amount)
	_color[_count] = color
	_count += 1


func _process(delta: float) -> void:
	for i in range(_count - 1, -1, -1):
		_age[i] += delta
		if _age[i] >= LIFETIME:
			_count -= 1
			_pos[i] = _pos[_count]
			_age[i] = _age[_count]
			_rot[i] = _rot[_count]
			_color[i] = _color[_count]
			_text[i] = _text[_count]
	queue_redraw()


func _draw() -> void:
	var f: Font = font if font else ThemeDB.fallback_font
	for i in _count:
		var s := _scale_at(_age[i] / LIFETIME)
		if s <= 0.01:
			continue
		# Posición, rotación y escala alrededor del punto de spawn
		draw_set_transform(_pos[i], _rot[i], Vector2(s, s))
		# Caja de 200px centrada en el origen; el offset en Y centra el texto verticalmente
		draw_string(f, Vector2(-100, font_size * 0.35), _text[i],
				HORIZONTAL_ALIGNMENT_CENTER, 200, font_size, _color[i])
	# Restauramos la transformación para no afectar otros dibujos
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _scale_at(t: float) -> float:
	if t < POP_END:
		return _ease_out_back(t / POP_END)
	if t < SHRINK_START:
		return 1.0
	var x := (t - SHRINK_START) / (1.0 - SHRINK_START)
	return 1.0 - ease(x, 2.0)


func _ease_out_back(x: float) -> float:
	const C1 := 1.70158
	const C3 := C1 + 1.0
	return 1.0 + C3 * pow(x - 1.0, 3.0) + C1 * pow(x - 1.0, 2.0)


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
