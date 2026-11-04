shader_type canvas_item;

uniform float frame_count = 3.0;
uniform vec3 flash_color : source_color = vec3(1.0);

varying float v_flash;
varying float v_fade;

void vertex() {
	UV.y = (UV.y + INSTANCE_CUSTOM.x) / frame_count;
	v_flash = INSTANCE_CUSTOM.y;
	v_fade = INSTANCE_CUSTOM.z;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float f = v_flash * v_flash;
	COLOR = vec4(mix(tex.rgb, flash_color, f), tex.a * (1.0 - v_fade));
}