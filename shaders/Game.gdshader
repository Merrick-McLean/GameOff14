shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 0.1;
uniform float density : hint_range(0.1, 1.0) = 0.01;
uniform float brightness : hint_range(0.0, 1.0) = 0.5;

uniform bool wetwave = false;
uniform bool heatwave = false;

uniform float fade : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.221, 31121.7))) * 1234.123);
}

void fragment() {
    COLOR = vec4(0.0); // base

    if (wetwave) {
        vec2 uv = UV;
        uv.y += TIME * speed;
        uv.x += uv.y * 0.15;

        float drops = hash(floor(uv * 500.0));
        float streak = step(1.0 - density, drops);
        streak *= smoothstep(0.0, 0.01, abs(fract(uv.y * 50.0) - 0.5));

        float amount = streak * brightness * fade; //
        COLOR = vec4(vec3(0.2, 0.4, 1.0) * amount, amount);
    }

    if (heatwave) {
        float amount = brightness * fade; //
        COLOR = vec4(vec3(1.0, 0.7, 0.0) * amount, 0.25 * fade);
    }
}
