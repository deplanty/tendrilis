shader_type canvas_item;

void fragment() {
	vec2 uv_center = abs(UV - vec2(.5));
	
	vec4 black = vec4(vec3(0.), 1.);
	COLOR = mix(COLOR, black, uv_center.y);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
