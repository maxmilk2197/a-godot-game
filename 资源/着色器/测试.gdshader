shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 gradient_color = mix(bottom_color, top_color, UV.y);
    COLOR = gradient_color;
    COLOR.a *= tex_color.a;
}