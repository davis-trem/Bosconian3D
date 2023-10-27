shader_type spatial;

uniform bool has_died = false;

void fragment() {
	if ((0.55 > UV.y && UV.y > 0.45) || UV.y < 0.1) {
		ALBEDO = vec3(0.2, 0, 0.5);
	} else {
		ALBEDO = vec3(0, 0.7, 0);
	}
	
	if (has_died && UV.y < 0.5) {
		ALPHA = 0.0;
	}
}
