class_name M3Theme
extends RefCounted
## ============================================================
## Material Design 3 主题令牌与样式工具（GDScript 版）。
## 纯静态，不需要 autoload：直接 M3Theme.primary 这样用。
##
## 默认是浅色 + 蓝色种子（与项目现有配色一致）。
## 想换主题色：改这里的令牌，或调用 M3Theme.应用种子(颜色)。
## ============================================================

# ---------------- 颜色令牌（浅色） ----------------
static var primary: Color = Color(0, 0.349, 0.78)
static var on_primary: Color = Color(1, 1, 1)
static var primary_container: Color = Color(0.851, 0.886, 1)
static var on_primary_container: Color = Color(0, 0.102, 0.263)

static var secondary: Color = Color(0.341, 0.369, 0.443)
static var on_secondary: Color = Color(1, 1, 1)
static var secondary_container: Color = Color(0.859, 0.886, 0.976)
static var on_secondary_container: Color = Color(0.078, 0.106, 0.173)

static var tertiary: Color = Color(0.447, 0.333, 0.451)
static var on_tertiary: Color = Color(1, 1, 1)
static var tertiary_container: Color = Color(0.988, 0.843, 0.984)
static var on_tertiary_container: Color = Color(0.165, 0.075, 0.176)

static var error: Color = Color(0.729, 0.102, 0.102)
static var on_error: Color = Color(1, 1, 1)
static var error_container: Color = Color(1, 0.855, 0.839)
static var on_error_container: Color = Color(0.255, 0, 0.008)

static var surface: Color = Color(0.996, 0.984, 1)
static var on_surface: Color = Color(0.106, 0.106, 0.122)
static var surface_variant: Color = Color(0.882, 0.886, 0.925)
static var on_surface_variant: Color = Color(0.267, 0.275, 0.31)

static var surface_container_low: Color = Color(0.949, 0.953, 0.988)
static var surface_container: Color = Color(0.918, 0.933, 0.984)
static var surface_container_high: Color = Color(0.886, 0.914, 0.976)

static var outline: Color = Color(0.459, 0.467, 0.502)
static var outline_variant: Color = Color(0.773, 0.776, 0.816)
static var shadow: Color = Color(0, 0, 0)

## 全局尺寸缩放（想让整套组件整体放大/缩小时改这个）
static var scale: float = 1.0

## 默认字体大小（组件会在此基础上按 scale 缩放）
static var font_size: int = 16


# ---------------- 尺寸 ----------------
## 按全局缩放换算像素
static func px(值: float) -> float:
	return 值 * scale


## 按全局缩放换算字号（至少 1）
static func fs(基准: int) -> int:
	return maxi(1, int(round(基准 * scale)))


# ---------------- 样式构造 ----------------
## 实心圆角样式
static func 样式(背景: Color, 圆角: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = 背景
	sb.set_corner_radius_all(maxi(0, int(round(圆角 * scale))))
	return sb


## 描边样式（透明底 + 边框）
static func 描边样式(描边色: Color, 圆角: int = 16, 线宽: int = 1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_corner_radius_all(maxi(0, int(round(圆角 * scale))))
	sb.set_border_width_all(maxi(1, int(round(线宽 * scale))))
	sb.border_color = 描边色
	return sb


## 带阴影 / 海拔的圆角样式
static func 海拔样式(背景: Color, 圆角: int = 16, 海拔: int = 1) -> StyleBoxFlat:
	var sb := 样式(背景, 圆角)
	if 海拔 > 0:
		sb.shadow_color = Color(0, 0, 0, 0.14 + 0.04 * 海拔)
		sb.shadow_size = int(round(海拔 * 2 * scale))
		sb.shadow_offset = Vector2(0, round(海拔 * scale))
	return sb


## 状态层样式（悬停/按下时叠加的半透明色）
static func 状态层(底色: Color, 叠加色: Color, 圆角: int, 透明度: float) -> StyleBoxFlat:
	var 混合 := 底色.lerp(叠加色, 透明度)
	return 样式(混合, 圆角)


# ---------------- 主题色派生 ----------------
## 按一个种子色粗略派生整套令牌（简化版 HSL 派生，够日常用）
static func 应用种子(种子: Color) -> void:
	primary = 种子
	on_primary = _对比色(种子)
	primary_container = 种子.lerp(Color(1, 1, 1), 0.8)
	on_primary_container = 种子.lerp(Color(0, 0, 0), 0.75)

	secondary = 种子.lerp(Color(0.4, 0.4, 0.4), 0.62)
	on_secondary = _对比色(secondary)
	secondary_container = 种子.lerp(Color(1, 1, 1), 0.86)
	on_secondary_container = 种子.lerp(Color(0, 0, 0), 0.8)

	tertiary = Color.from_hsv(fmod(种子.h + 0.333, 1.0), 种子.s, 种子.v)
	on_tertiary = _对比色(tertiary)
	tertiary_container = tertiary.lerp(Color(1, 1, 1), 0.82)
	on_tertiary_container = tertiary.lerp(Color(0, 0, 0), 0.78)

	surface = Color(0.996, 0.984, 1)
	on_surface = Color(0.106, 0.106, 0.122)
	surface_variant = 种子.lerp(Color(1, 1, 1), 0.9)
	on_surface_variant = 种子.lerp(Color(0, 0, 0), 0.7)
	surface_container_low = 种子.lerp(Color(1, 1, 1), 0.94)
	surface_container = 种子.lerp(Color(1, 1, 1), 0.91)
	surface_container_high = 种子.lerp(Color(1, 1, 1), 0.88)
	outline = 种子.lerp(Color(0.5, 0.5, 0.5), 0.6)
	outline_variant = 种子.lerp(Color(1, 1, 1), 0.78)


## 根据背景亮度挑黑或白（保证文字对比度）
static func _对比色(背景: Color) -> Color:
	return Color(0, 0, 0) if 背景.get_luminance() > 0.55 else Color(1, 1, 1)
