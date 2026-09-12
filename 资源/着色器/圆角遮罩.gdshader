shader_type canvas_item;

// 简单的圆角裁剪：rect_size 由脚本设为节点像素尺寸；corner_radius 为 0 时不裁剪。
uniform vec2 rect_size = vec2(0.0, 0.0);
uniform float corner_radius : hint_range(0.0, 200.0) = 0.0;

void fragment() {
	if (corner_radius > 0.0 && rect_size.x > 0.0 && rect_size.y > 0.0) {
		vec2 p = UV * rect_size;
		vec2 half_size = rect_size * 0.5;
		vec2 q = abs(p - half_size) - (half_size - vec2(corner_radius));
		float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner_radius;
		if (d > 0.0) {
			discard;
		}
	}

	COLOR = texture(TEXTURE, UV) * COLOR;
}
