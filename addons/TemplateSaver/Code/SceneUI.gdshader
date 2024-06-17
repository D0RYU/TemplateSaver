shader_type canvas_item;

uniform int num_colors: hint_range(2,16) = 8;
uniform sampler2D PALETTE_TEXTURE: hint_default_black;

uniform vec2 resolution = vec2(32, 32);

vec3 palette_limiter(in vec3 albedo){
	float estimation_cutoff = 0.001;
	vec3 closest_color;
	float min_dist = 2.0;
	float n = float(num_colors);
	
	for (int i = 0; i < num_colors; i++){
		float index = 1.000 / (2.000 * n) + float(i) / n;
		vec3 index_color = texture(PALETTE_TEXTURE, vec2(index, 0.5)).rgb;
		float dist = length(index_color - albedo);
		
		if (dist < min_dist) {
			min_dist = dist;
			closest_color = index_color;
			
			if (min_dist < estimation_cutoff){
				return closest_color;
			}
		}
	}
	
	return closest_color;
}

void fragment() {
	vec2 grid_uv = UV - mod(UV * resolution, 1) / resolution;
	vec3 color = palette_limiter(texture(TEXTURE, grid_uv).rgb);
	
	if(color.r < 1.0 && color.g < 1.0 && color.b < 1.0) {
		// 0.100392156862 is the cube root of 255
		vec3 rgb255 = vec3(0.100392156862, 0.100392156862, 0.100392156862);
		vec3 remainder = mod(color.rgb, rgb255);
		color.rgb -= remainder;
	}
	
	//COLOR = vec4(color, 1);
}