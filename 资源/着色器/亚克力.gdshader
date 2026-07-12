shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform float strength : hint_range(0.1, 20.0) = 3.3;
uniform float opacity : hint_range(0.0, 1.0) = 0.85;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float noise_amount : hint_range(0.0, 0.1) = 0.03;
uniform float noise_scale : hint_range(0.1, 10.0) = 4.0;

float gaussianDistribution(float x, float STD) {
	return exp(-(x * x) / (2.0 * STD * STD)) / (sqrt(2.0 * PI) * STD);
}

vec3 gaussianblur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius) {
	vec3 blurredPixel = vec3(0.0);
	float total_weight = 0.0;
	for (int i = -radius; i <= radius; i++) {
		for (int j = -radius; j <= radius; j++) {
			vec2 offset = vec2(float(i), float(j)) * pixel_size;
			vec2 changedPos = pos + offset;
			float weight = gaussianDistribution(float(i), sigmaUsed) * gaussianDistribution(float(j), sigmaUsed);
			blurredPixel += texture(SCREEN_TEXTURE, changedPos).rgb * weight;
			total_weight += weight;
		}
	}
	blurredPixel /= total_weight;
	return blurredPixel;
}

void fragment() {
	vec3 pixel_blurred = gaussianblur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE, strength, int(round(3.0 * strength)));
	vec3 blurred_with_tint = mix(pixel_blurred, tint_color.rgb, tint_color.a);

	float noise = texture(noise_texture, SCREEN_UV * noise_scale).r - 0.5;
	vec3 final_color = blurred_with_tint + noise * noise_amount;

	COLOR = vec4(final_color, opacity);
}
