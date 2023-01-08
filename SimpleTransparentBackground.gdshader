shader_type canvas_item;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	// Place fragment code here.
	float t = texture(TEXTURE, UV).r;
	float alpha = smoothstep(0, 0.001, t);
	COLOR =  alpha * vec4(0,0,0,1) * (1.0 - t) + modulate * (t);
}
