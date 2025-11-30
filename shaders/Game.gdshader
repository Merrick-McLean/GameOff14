shader_type canvas_item;

uniform float fade : hint_range(0.0, 1.0) = 0.0; // for opacity control
uniform bool heatwave = false;
uniform bool wetwave = false;

uniform int count: hint_range(0, 2000) = 500;
uniform float slant: hint_range(-0.1, 0.1) = -0.01;
uniform float speed: hint_range(25.0, 100.0) = 75.0;
uniform float blur: hint_range(0.0005, 0.1) = 0.002;
uniform vec4 colour: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 size = vec2(0.005, 0.2);

uniform float brightness = 0.8;

float line_sdf(vec2 p, vec2 s) {
    vec2 d = abs(p) - s;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float Hash(float x) {
    return fract(sin(x * 18.34) * 51.78);
}

float Hash2(float x) {
    return fract(sin(x * 25.42) * 21.24);
}


void fragment() {
	if(wetwave && false){
    vec2 s = size * 0.1;
    float time = TIME + 1000.0;
    vec2 uv = UV;
    uv.x += uv.y * slant;
    float output = 0.0;
    
    for (int i = 1; i <= count; i++) {
        float h1 = Hash(float(i));
        float h2 = Hash2(float(i));

        float sl = h1 * uv.y * -slant;
        float pos_mod_x = h1 * 1.2;
        float pos_mod_y = max(h2 * speed, pos_mod_x * speed);
        vec2 position = vec2(pos_mod_x + sl, -mod(-pos_mod_y * time * 0.1, -1.));
        float sdf = line_sdf(uv - position, s);
        output += clamp(- sdf / blur, 0.0, 1.0);
    }
	
		    // Background color (blue-ish)
		vec3 background_color = vec3(0.2, 0.3, 0.6); // slightly desaturated, dark blue

		vec3 final_color = mix(
		    background_color,    
		    colour.rgb,           
		    clamp(output * fade, 0.0, 1.0)
		);

		COLOR = vec4(final_color*-fade, 0.4);
	}
	
	if (wetwave){
		float amount = brightness * fade;
        COLOR = vec4(vec3(0.1, 0.1, 0.8) * amount, 0.25 * fade);
	}

    if (heatwave) {
        float amount = brightness * fade;
        COLOR = vec4(vec3(1.0, 0.7, 0.0) * amount, 0.25 * fade);
    }
}
