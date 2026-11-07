shader_type canvas_item;

uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	COLOR = vec4(tint.rgb, COLOR.a * tint.a);
}