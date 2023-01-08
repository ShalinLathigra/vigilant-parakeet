shader_type canvas_item;

uniform float t: hint_range(-0.01, 1);
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(0,0,0,1) * step(tex.r, t);
}