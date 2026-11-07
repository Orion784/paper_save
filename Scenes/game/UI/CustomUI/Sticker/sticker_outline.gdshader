shader_type canvas_item;

uniform vec4 color_1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_2 : source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform vec4 color_3 : source_color = vec4(0.2, 1.0, 0.2, 1.0);
uniform vec4 color_4 : source_color = vec4(0.2, 0.2, 1.0, 1.0);
uniform int selected : hint_range(0, 3, 1) = 0;

void fragment() {
	vec4 colors[4] = vec4[4](color_1, color_2, color_3, color_4);
	vec4 c = colors[selected];
	COLOR = vec4(c.rgb, COLOR.a * c.a);
}