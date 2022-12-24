shader_type canvas_item;

void fragment() {
	// asset the original shader
	vec4 original_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, original_color.a * 0.8);
	COLOR = white_color;
}
