shader_type canvas_item;

uniform float radius;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
    float distance_from_center = length(UV - center);

    float circle_radius = radius / 2.0;

    if (distance_from_center > circle_radius) {
        discard;
    }
}
