shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 1.5;
uniform float density : hint_range(0.1, 1.0) = 0.5; 
uniform float brightness : hint_range(0.0, 1.0) = 0.7;

uniform bool poland = false;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	if (poland) {
	vec2 uv = UV;
	uv.y += TIME * speed;
	uv.x += uv.y * 0.15;
	float drops = hash(floor(uv * 500.0));
	float streak = step(1.0 - density, drops);
	streak *= smoothstep(0.0, 0.01, abs(fract(uv.y * 50.0) - 0.5));

	    COLOR = vec4(vec3(0.2, 0.4, 1.0) * streak * brightness, streak);	
		
	}
}
