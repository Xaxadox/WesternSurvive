shader_type canvas_item;

uniform int light_count = 0;
uniform vec4 light0 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light1 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light2 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light3 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light4 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light5 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light6 = vec4(-10000.0, -10000.0, 1.0, 0.0);
uniform vec4 light7 = vec4(-10000.0, -10000.0, 1.0, 0.0);

float light_alpha(vec2 point, vec4 light_data, float current_alpha) {
	float radius = max(light_data.z, 1.0);
	float distance_to_light = distance(point, light_data.xy);
	float inner = radius * 0.34;
	float falloff = smoothstep(inner, radius, distance_to_light);
	float alpha = mix(0.06, 0.86, falloff);
	return min(current_alpha, alpha);
}

void fragment() {
	vec2 point = FRAGCOORD.xy;
	float alpha = 0.88;

	if (light_count > 0) { alpha = light_alpha(point, light0, alpha); }
	if (light_count > 1) { alpha = light_alpha(point, light1, alpha); }
	if (light_count > 2) { alpha = light_alpha(point, light2, alpha); }
	if (light_count > 3) { alpha = light_alpha(point, light3, alpha); }
	if (light_count > 4) { alpha = light_alpha(point, light4, alpha); }
	if (light_count > 5) { alpha = light_alpha(point, light5, alpha); }
	if (light_count > 6) { alpha = light_alpha(point, light6, alpha); }
	if (light_count > 7) { alpha = light_alpha(point, light7, alpha); }

	COLOR = vec4(0.012, 0.010, 0.008, alpha);
}
