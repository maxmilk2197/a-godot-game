shader_type canvas_item;
// ============================================================
// 夜晚色调：保留瓦片原来的明暗关系，把颜色换成冷蓝色
//
// 为什么不用 modulate：modulate 是乘法，草地蓝色分量本来就低，
// 乘一个偏蓝的颜色只会「更暗」，变不蓝。shader 能提取明度再重新上色。
//
// night_amount = 0 → 完全src（白天）
// night_amount = 1 → 完全冷蓝（夜晚）
// ============================================================

uniform float night_amount : hint_range(0.0, 1.0) = 0.0;
// 夜晚主色调（深灰蓝），可按地图调
uniform vec3 night_tint : source_color = vec3(0.32, 0.52, 0.92);
// 夜晚lum度系数，越大越lum
uniform float night_gain : hint_range(0.0, 3.0) = 1.35;
// 夜晚饱和度：越低越灰
uniform float night_desat : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	if (src.a < 0.01 || night_amount < 0.001) {
		COLOR = src;
	} else {
		// 用lum度当遮罩，瓦片上的草丛、花朵、阴影全都会保留形状
		float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

		// night = 主色调 × lum度；压掉一点饱和让它更像月光下的草地
		vec3 night = night_tint * (lum * night_gain);
		night = mix(night, vec3(lum * night_gain), night_desat);

		vec3 result = mix(src.rgb, night, night_amount);
		COLOR = vec4(result, src.a);
	}
}
