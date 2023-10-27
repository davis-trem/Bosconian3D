shader_type spatial;

void fragment() {
	ALBEDO = vec3(0, 0.7, 0);
	if (0.71 >= UV.y && UV.y > 0.29) {
		ALPHA = 0.0;
	}
}
